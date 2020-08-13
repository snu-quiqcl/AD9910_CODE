# -*- coding: utf-8 -*-
"""
Created on Wed Apr  4 00:10:48 2018

@author: 1109282

* Change log
v1_00: Initial working version with DDS1 olny
v1_01: Working with DDS1 & DDS2
v1_02: Adding oscilloscope

"""
# from http://wiki.python.org/moin/TcpCommunication
# About SCPI over TCP: page 12 from ftp://ftp.datx.com/Public/DataAcq/MeasurementInstruments/Manuals/SCPI_Measurement.pdf

from __future__ import unicode_literals
import os, sys
filename = os.path.abspath(__file__)
dirname = os.path.dirname(filename)

new_path_list = []
new_path_list.append(dirname + '\\ui_resources') # For resources_rc.py
# More paths can be added here...
for each_path in new_path_list:
    if not (each_path in sys.path):
        sys.path.append(each_path)

import ImportForSpyderAndQt5
from ds1054z import DS1054Z # To install the package, open "Anaconda Prompt", type "pip install ds1054z[savescreen,discovery]"

from PyQt5 import uic
qt_designer_file = dirname + '\\DDS_DAC_UI_v1_02.ui'
Ui_QDialog, QtBaseClass = uic.loadUiType(qt_designer_file)
ICON_ON = ":/icons/Toggle_Switch_ON_64x34.png"
ICON_OFF = ":/icons/Toggle_Switch_OFF_64x34.png"


from PyQt5 import QtWidgets, QtGui, QtCore
from PyQt5.QtWidgets import QMessageBox
from matplotlib.figure import Figure
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
import matplotlib.pyplot as plt
import numpy as np

import math
import socket
from shutil import copyfile
import configparser
from code_editor.code_editor_v2_00 import TextEditor

class DDS_DAC(QtWidgets.QDialog, Ui_QDialog):
    
    def __init__(self, parent=None, connection_callback=None):
        QtWidgets.QDialog.__init__(self, parent)
        #self.setAttribute(QtCore.Qt.WA_DeleteOnClose)
        self.setupUi(self)
        
        self.DDS1_old_Vpp_stepBy = self.DDS1_Vpp_spinbox.stepBy
        self.DDS1_Vpp_spinbox.stepBy = self.DDS1_new_Vpp_stepBy

        self.DDS1_old_mW_stepBy = self.DDS1_mW_spinbox.stepBy
        self.DDS1_mW_spinbox.stepBy = self.DDS1_new_mW_stepBy

        self.DDS1_old_dBm_stepBy = self.DDS1_dBm_spinbox.stepBy
        self.DDS1_dBm_spinbox.stepBy = self.DDS1_new_dBm_stepBy

        self.DDS1_old_freq_stepBy = self.DDS1_freq_spinbox.stepBy
        self.DDS1_freq_spinbox.stepBy = self.DDS1_new_freq_stepBy
        self.DDS1_prev_freq_unit_index = self.DDS1_freq_unit.currentIndex()

        self.DDS2_old_Vpp_stepBy = self.DDS2_Vpp_spinbox.stepBy
        self.DDS2_Vpp_spinbox.stepBy = self.DDS2_new_Vpp_stepBy

        self.DDS2_old_mW_stepBy = self.DDS2_mW_spinbox.stepBy
        self.DDS2_mW_spinbox.stepBy = self.DDS2_new_mW_stepBy

        self.DDS2_old_dBm_stepBy = self.DDS2_dBm_spinbox.stepBy
        self.DDS2_dBm_spinbox.stepBy = self.DDS2_new_dBm_stepBy

        self.DDS2_old_freq_stepBy = self.DDS2_freq_spinbox.stepBy
        self.DDS2_freq_spinbox.stepBy = self.DDS2_new_freq_stepBy
        self.DDS2_prev_freq_unit_index = self.DDS2_freq_unit.currentIndex()
        
        self.connected = False
        self.connection_callback = connection_callback
        
        self.on_pixmap = QtGui.QPixmap(ICON_ON)
        self.on_icon = QtGui.QIcon(self.on_pixmap)

        self.off_pixmap = QtGui.QPixmap(ICON_OFF)
        self.off_icon = QtGui.QIcon(self.off_pixmap)

        self.DDS1_groupBox.setEnabled(False)
        self.DDS2_groupBox.setEnabled(False)
        
        self.config_editor = TextEditor(window_title = 'Config editor')
        config_dir = dirname + '\\config'
        self.config_filename = '%s\\%s.ini' % (config_dir, socket.gethostname())
        self.config_file_label.setText(self.config_filename)
        if not os.path.exists(self.config_filename):
            copyfile('%s\\default.ini' % config_dir, self.config_filename)
        self.reload_config()
        
        self.osc_connected = False
        self.prepare_plot_area()


        
    def prepare_plot_area(self):
        plt.rcParams.update({'figure.autolayout': True})
        self.fig = Figure(figsize=(4, 3), dpi=100)
        self.axes = self.fig.add_subplot(111)
                
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setParent(self.plot_widget)
        FigureCanvas.setSizePolicy(self.canvas,
                                   QtWidgets.QSizePolicy.Expanding,
                                   QtWidgets.QSizePolicy.Expanding)
        FigureCanvas.updateGeometry(self.canvas)
        
        l = QtWidgets.QVBoxLayout(self.plot_widget)
        l.addWidget(self.canvas)



        
    def reload_config(self):
        self.config = configparser.ConfigParser()
        self.config.read(self.config_filename)
        
        self.IP_address.setText(self.config['Dual DDS']['IP_address'])
        self.port.setText(self.config['Dual DDS']['port'])
        
        self.DDS1_auto_power_apply_checkbox.setChecked(self.config['DDS1']['power_auto_apply'] == 'True')
        self.DDS1_auto_freq_apply_checkbox.setChecked(self.config['DDS1']['freq_auto_apply'] == 'True')
        self.sync_checkBox.setChecked(self.config['DDS1']['sync_DDS2_freq'] == 'True')
        
        self.DDS2_auto_power_apply_checkbox.setChecked(self.config['DDS2']['power_auto_apply'] == 'True')
        self.DDS2_auto_freq_apply_checkbox.setChecked(self.config['DDS2']['freq_auto_apply'] == 'True')
        
        self.osc_IP_address.setText(self.config['Oscilloscope']['osc_IP_address'])
        self.osc_auto_update_checkBox.setChecked(self.config['Oscilloscope']['osc_auto_update'] == 'True')
          
          
    def edit_config(self):
        self.config_editor.show()
        self.config_editor.open_document_by_external(self.config_filename)

    def config_changed(self):
        self.config = configparser.ConfigParser()
        self.config.read(self.config_filename)
        
        if (self.config['Dual DDS']['IP_address'] != self.IP_address.text()):
            return True
        if (self.config['Dual DDS']['port'] != self.port.text()):
            return True

        if self.DDS1_auto_power_apply_checkbox.isChecked() != (self.config['DDS1']['power_auto_apply'] == 'True'):
            return True
        if self.DDS1_auto_freq_apply_checkbox.isChecked() != (self.config['DDS1']['freq_auto_apply'] == 'True'):
            return True
        if self.sync_checkBox.isChecked() != (self.config['DDS1']['sync_DDS2_freq'] == 'True'):
            return True
        
        if self.DDS2_auto_power_apply_checkbox.isChecked() != (self.config['DDS2']['power_auto_apply'] == 'True'):
            return True
        if self.DDS2_auto_freq_apply_checkbox.isChecked() != (self.config['DDS2']['freq_auto_apply'] == 'True'):
            return True
        
        if self.osc_IP_address.text() != self.config['Oscilloscope']['osc_IP_address']:
            return True
        if self.osc_auto_update_checkBox.isChecked() != (self.config['Oscilloscope']['osc_auto_update'] == 'True'):
            return True
        
        return False

    
    def save_config(self):
        self.config = configparser.ConfigParser()
        self.config.read(self.config_filename)
        
        self.config['Dual DDS']['IP_address'] = self.IP_address.text()
        self.config['Dual DDS']['port'] = self.port.text()

        self.config['DDS1']['power_auto_apply'] = str(self.DDS1_auto_power_apply_checkbox.isChecked())
        self.config['DDS1']['freq_auto_apply'] = str(self.DDS1_auto_freq_apply_checkbox.isChecked())
        self.config['DDS1']['sync_DDS2_freq'] = str(self.sync_checkBox.isChecked())
        
        self.config['DDS2']['power_auto_apply'] = str(self.DDS2_auto_power_apply_checkbox.isChecked())
        self.config['DDS2']['freq_auto_apply'] = str(self.DDS2_auto_freq_apply_checkbox.isChecked())
        
        self.config['Oscilloscope']['osc_IP_address'] = self.osc_IP_address.text()
        self.config['Oscilloscope']['osc_auto_update'] = str(self.osc_auto_update_checkBox.isChecked())


        with open(self.config_filename, 'w') as new_config_file:
            self.config.write(new_config_file)


    def query(self, message):
        """ Send the message and read the reply.
        
        Args:
            query (unicode string): query
        
        Returns:
            unicode string: reply string
        """
        self.socket.send((message+'\n').encode('latin-1'))
        data = self.socket.recv(1024)
        data_decoded = data.decode('latin-1')
        if data_decoded[-1] != '\n':
            print(data_decoded)
            raise ValueError('Error in query: the returned message is not finished with \"\\n\"')
            
        return data_decoded[:-1] # Removing the trailing '\n'

    
    def write(self, message):
        """ Send the command.
        
        Args:
            message (unicode string): message to send
        
        Returns:
            None
        """
        self.socket.send((message + '\n').encode('latin-1'))


    def read(self):
        """ Reads data from the device.
        
        Args:
            None
        
        Returns:
            unicode string: received string
        """
        data = self.socket.recv(1024)
        data_decoded = data.decode('latin-1')
        if data_decoded[-1] != '\n':
            raise ValueError('Error in read: the returned message is not finished with \\n')
            
        return data_decoded[:-1] # Removing the trailing '\n'
        




    
    def closeEvent(self, event):

        if hasattr(self, 'socket') and self.socket.fileno() != -1:
            buttonReply = QMessageBox.warning(self, 'Connection to dual DDS is still open', \
                'Do you want to close the connection to the device?', \
                QMessageBox.Yes | QMessageBox.No | QMessageBox.Cancel, QMessageBox.No)
            if buttonReply == QMessageBox.Cancel:
                event.ignore()
                return
            elif buttonReply == QMessageBox.Yes:
                self.socket.close()
                if self.connection_callback != None:
                    self.connection_callback(False)

        if self.osc_connected:
            self.connect_to_osc() # If oscilloscope is still connected, disconnect it
                    
        if self.config_changed():
            self.save_config()

        # Clean-up
        self.DDS1_Vpp_spinbox.stepBy = self.DDS1_old_Vpp_stepBy
        self.DDS1_mW_spinbox.stepBy = self.DDS1_old_mW_stepBy
        self.DDS1_dBm_spinbox.stepBy = self.DDS1_old_dBm_stepBy
        self.DDS1_freq_spinbox.stepBy = self.DDS1_old_freq_stepBy

        self.DDS2_Vpp_spinbox.stepBy = self.DDS2_old_Vpp_stepBy
        self.DDS2_mW_spinbox.stepBy = self.DDS2_old_mW_stepBy
        self.DDS2_dBm_spinbox.stepBy = self.DDS2_old_dBm_stepBy
        self.DDS2_freq_spinbox.stepBy = self.DDS2_old_freq_stepBy

            
    def connect_to_osc(self):
        global osc, old_osc_TCP
        if self.osc_connected:
            osc.close()
            self.osc_IDN_label.setText('')
            
            self.osc_connection_status.setText('Disconnected')
            self.osc_connect_button.setText('Connect')
            self.osc_update_pushButton.setEnabled(False)
            self.osc_connected = False
            
        else:
            if 'osc' in globals() and old_osc_TCP == self.osc_IP_address.text():
                osc.open()
            else:
                osc = DS1054Z(self.osc_IP_address.text())
                old_osc_TCP = self.osc_IP_address.text()
            self.osc_IDN_label.setText(osc.idn) # 'RIGOL TECHNOLOGIES,DS1054Z,DS1ZA195222878,00.04.04.SP3'

            self.osc_connection_status.setText('Connected')
            self.osc_connect_button.setText('Disconnect')
            self.osc_update_pushButton.setEnabled(True)
            self.osc_connected = True


    def osc_update(self):
        global osc
        chan1_data = osc.get_waveform_samples('CHAN1')
        x_data = np.linspace(0, 12*osc.timebase_scale, len(chan1_data))
        self.axes.cla()
        self.axes.plot(x_data*1e9, chan1_data)
        #self.axes.set(xlabel='Time (ns)', ylabel='Voltage (V)')
        self.axes.set(ylabel='Voltage (V)')
        self.axes.set_ylim([-0.2,0.2])
        self.axes.grid()
        self.canvas.draw()
        
        

        

    def connect_to_DDS(self):
        if self.connected:
            self.socket.close() 
            self.IDN_label.setText('')
            
            self.connection_status.setText('Disconnected')
            self.connect_button.setText('Connect')
            self.DDS1_groupBox.setEnabled(False)
            self.DDS2_groupBox.setEnabled(False)
            self.connected = False
            if self.connection_callback != None:
                self.connection_callback(False)

            
        else:
            self.TCP_IP = self.IP_address.text()
            self.TCP_PORT = int(self.port.text())
            
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect((self.TCP_IP, self.TCP_PORT))
            self.socket.settimeout(1) # unit in second?
            
            connection_status = self.read()
            if connection_status[:2] == 'A:':
                QMessageBox.critical(self, 'Connection to Dual DDS server failed', \
                    ('There is another active connection. Please disconnect another connection from %s first.' % str(connection_status[2:])), \
                    QMessageBox.Ok, QMessageBox.Ok)
                return
            elif connection_status[:2] == 'C:':
                #print('This connection became active')
                pass

            self.IDN_label.setText(self.query('*IDN?')) # 'TCP Server for Dual DDS with trigger output v1.00'

            #print(self.query('Q:DDS1:RFOUT'))

            if self.query('Q:DDS1:RFOUT') == 'False':
                self.DDS1_output_button.setIcon(self.off_icon)
                self.DDS1_output_on = False
            else:
                self.DDS1_output_button.setIcon(self.on_icon)
                self.DDS1_output_on = True

            self.DDS1_read_power()
            self.DDS1_read_freq()


            if self.query('Q:DDS2:RFOUT') == 'False':
                self.DDS2_output_button.setIcon(self.off_icon)
                self.DDS2_output_on = False
            else:
                self.DDS2_output_button.setIcon(self.on_icon)
                self.DDS2_output_on = True

            if self.query('Q:DDS2:TRIG') == 'False':
                self.DDS2_trigger_button.setIcon(self.off_icon)
                self.DDS2_trigger_on = False
            else:
                self.DDS2_trigger_button.setIcon(self.on_icon)
                self.DDS2_trigger_on = True

            self.DDS2_read_power()
            self.DDS2_read_freq()
            
            self.connection_status.setText('Connected')
            self.connect_button.setText('Disconnect')
            self.DDS1_groupBox.setEnabled(True)
            self.DDS2_groupBox.setEnabled(True)
            self.connected = True
            if self.connection_callback != None:
                self.connection_callback(True)
            
            



    def DDS1_read_power(self):
        dBm = float(self.query('Q:DDS1:POWER'))
        self.DDS1_dBm_spinbox.setValue(dBm)
        mW = 10**(dBm/10)
        Vamp = math.sqrt(mW/10)
        self.DDS1_mW_spinbox.setValue(mW)
        self.DDS1_Vpp_spinbox.setValue(2*Vamp)
    
    def DDS1_apply_power(self):
        dBm = self.DDS1_dBm_spinbox.value()
        self.write('DDS1:POWER %.2f' % dBm)
    
    def DDS1_read_freq(self):
        query = 'Q:DDS1:FREQ'
        freq_in_MHz = float(self.query(query))
        
        DDS1_freq_unit_index = self.DDS1_freq_unit.currentIndex()
        scale = 10**(3*DDS1_freq_unit_index)
        
        self.DDS1_freq_spinbox.setValue((freq_in_MHz*1e6)/scale)

    
    def DDS1_apply_freq(self):
        DDS1_freq_unit_index = self.DDS1_freq_unit.currentIndex()
        scale = 10**(3*DDS1_freq_unit_index)
        freq_in_MHz = self.DDS1_freq_spinbox.value() * scale /1e6
        
        if self.sync_checkBox.isChecked():
            self.DDS2_freq_unit.setCurrentIndex(DDS1_freq_unit_index)
            self.DDS2_freq_spinbox.setValue(self.DDS1_freq_spinbox.value())
            self.write('DDS:FREQ %f' % freq_in_MHz)
        else:
            self.write('DDS1:FREQ %f' % freq_in_MHz)

    def DDS1_output_on_off(self):
        if self.DDS1_output_on:
            self.write('DDS1:RFOUT False')
            self.DDS1_output_button.setIcon(self.off_icon)
            self.DDS1_output_on = False
        else:
            self.write('DDS1:RFOUT True')
            self.DDS1_output_button.setIcon(self.on_icon)
            self.DDS1_output_on = True


    def DDS1_new_freq_stepBy(self, steps):
        self.DDS1_old_freq_stepBy(steps)
        self.DDS1_freq_updated()

    def DDS1_freq_editing_finished(self):
        self.DDS1_freq_updated()

    def DDS1_freq_updated(self):
        #print('Freq', self.DDS1_freq_spinbox.value())
        if self.DDS1_auto_freq_apply_checkbox.isChecked():
            self.DDS1_apply_freq()

    
    def DDS1_freq_unit_changed(self, index):
        #print('freq_unit_changed', self.DDS1_freq_unit.currentIndex())
        DDS1_new_freq_unit_index = self.DDS1_freq_unit.currentIndex()
        scale = 10**(3*(DDS1_new_freq_unit_index - self.DDS1_prev_freq_unit_index))
        
        self.DDS1_freq_spinbox.setValue(self.DDS1_freq_spinbox.value()/scale)
        self.DDS1_freq_step_size.setText(str(float(self.DDS1_freq_step_size.text())/scale))
        
        self.DDS1_prev_freq_unit_index = DDS1_new_freq_unit_index
    
    def DDS1_freq_step_size_changed(self):
        self.DDS1_freq_spinbox.setSingleStep(float(self.DDS1_freq_step_size.text()))
    

    def DDS1_new_Vpp_stepBy(self, steps):
        self.DDS1_old_Vpp_stepBy(steps)
        self.DDS1_Vpp_updated()
        
    def DDS1_Vpp_editing_finished(self):
        self.DDS1_Vpp_updated()

    def DDS1_Vpp_updated(self):
        #print('Vpp', self.DDS1_Vpp_spinbox.value())
        
        Vamp=self.DDS1_Vpp_spinbox.value()/2
        mW=10*Vamp**2
        if mW > 0:
            dBm = 10*math.log10(mW)
        else:
            dBm = -1000
        self.DDS1_mW_spinbox.setValue(mW)
        self.DDS1_dBm_spinbox.setValue(dBm)
        
        if self.DDS1_auto_power_apply_checkbox.isChecked():
            self.DDS1_apply_power()

    def DDS1_Vpp_step_size_changed(self):
        self.DDS1_Vpp_spinbox.setSingleStep(float(self.DDS1_Vpp_step_size.text()))



    def DDS1_new_mW_stepBy(self, steps):
        self.DDS1_old_mW_stepBy(steps)
        self.DDS1_mW_updated()
        
    def DDS1_mW_editing_finished(self):
        self.DDS1_mW_updated()

    def DDS1_mW_updated(self):
        #print('mW', self.DDS1_mW_spinbox.value())

        mW = self.DDS1_mW_spinbox.value()
        Vamp = math.sqrt(mW/10)
        if mW > 0:
            dBm = 10*math.log10(mW)
        else:
            dBm = -1000
        self.DDS1_Vpp_spinbox.setValue(2*Vamp)
        self.DDS1_dBm_spinbox.setValue(dBm)
        
        if self.DDS1_auto_power_apply_checkbox.isChecked():
            self.DDS1_apply_power()

    def DDS1_mW_step_size_changed(self):
        self.DDS1_mW_spinbox.setSingleStep(float(self.DDS1_mW_step_size.text()))


    def DDS1_set_power_mW(self, mW):
        self.DDS1_mW_spinbox.setValue(mW)
        Vamp = math.sqrt(mW/10)
        if mW > 0:
            dBm = 10*math.log10(mW)
        else:
            dBm = -1000
        self.DDS1_Vpp_spinbox.setValue(2*Vamp)
        self.DDS1_dBm_spinbox.setValue(dBm)
        
        self.DDS1_apply_power()
        
        
    def DDS1_set_freq_Hz(self, Hz):
        DDS1_freq_unit_index = self.DDS1_freq_unit.currentIndex()
        scale = 10**(3*DDS1_freq_unit_index)
        
        self.DDS1_freq_spinbox.setValue(Hz/scale)
        self.DDS1_apply_freq()


    def DDS1_new_dBm_stepBy(self, steps):
        self.DDS1_old_dBm_stepBy(steps)
        self.DDS1_dBm_updated()
        
    def DDS1_dBm_editing_finished(self):
        self.DDS1_dBm_updated()

    def DDS1_dBm_updated(self):
        #print('dBm', self.DDS1_dBm_spinbox.value())

        dBm = self.DDS1_dBm_spinbox.value()
        mW = 10**(dBm/10)
        Vamp = math.sqrt(mW/10)
        self.DDS1_mW_spinbox.setValue(mW)
        self.DDS1_Vpp_spinbox.setValue(2*Vamp)
        
        if self.DDS1_auto_power_apply_checkbox.isChecked():
            self.DDS1_apply_power()

    def DDS1_dBm_step_size_changed(self):
        self.DDS1_dBm_spinbox.setSingleStep(float(self.DDS1_dBm_step_size.text()))










    def DDS2_read_power(self):
        dBm = float(self.query('Q:DDS2:POWER'))
        self.DDS2_dBm_spinbox.setValue(dBm)
        mW = 10**(dBm/10)
        Vamp = math.sqrt(mW/10)
        self.DDS2_mW_spinbox.setValue(mW)
        self.DDS2_Vpp_spinbox.setValue(2*Vamp)
    
    def DDS2_apply_power(self):
        dBm = self.DDS2_dBm_spinbox.value()
        self.write('DDS2:POWER %.2f' % dBm)
    
    def DDS2_read_freq(self):
        query = 'Q:DDS2:FREQ'
        freq_in_MHz = float(self.query(query))
        
        DDS2_freq_unit_index = self.DDS2_freq_unit.currentIndex()
        scale = 10**(3*DDS2_freq_unit_index)
        
        self.DDS2_freq_spinbox.setValue((freq_in_MHz*1e6)/scale)

    
    def DDS2_apply_freq(self):
        DDS2_freq_unit_index = self.DDS2_freq_unit.currentIndex()
        scale = 10**(3*DDS2_freq_unit_index)
        freq_in_MHz = self.DDS2_freq_spinbox.value() * scale /1e6
        self.write('DDS2:FREQ %f' % freq_in_MHz)

    def DDS2_output_on_off(self):
        if self.DDS2_output_on:
            self.write('DDS2:RFOUT False')
            self.DDS2_output_button.setIcon(self.off_icon)
            self.DDS2_output_on = False
        else:
            self.write('DDS2:RFOUT True')
            self.DDS2_output_button.setIcon(self.on_icon)
            self.DDS2_output_on = True


    def DDS2_new_freq_stepBy(self, steps):
        self.DDS2_old_freq_stepBy(steps)
        self.DDS2_freq_updated()

    def DDS2_freq_editing_finished(self):
        self.DDS2_freq_updated()

    def DDS2_freq_updated(self):
        #print('Freq', self.DDS2_freq_spinbox.value())
        if self.DDS2_auto_freq_apply_checkbox.isChecked():
            self.DDS2_apply_freq()

    
    def DDS2_freq_unit_changed(self, index):
        #print('freq_unit_changed', self.DDS2_freq_unit.currentIndex())
        DDS2_new_freq_unit_index = self.DDS2_freq_unit.currentIndex()
        scale = 10**(3*(DDS2_new_freq_unit_index - self.DDS2_prev_freq_unit_index))
        
        self.DDS2_freq_spinbox.setValue(self.DDS2_freq_spinbox.value()/scale)
        self.DDS2_freq_step_size.setText(str(float(self.DDS2_freq_step_size.text())/scale))
        
        self.DDS2_prev_freq_unit_index = DDS2_new_freq_unit_index
    
    def DDS2_freq_step_size_changed(self):
        self.DDS2_freq_spinbox.setSingleStep(float(self.DDS2_freq_step_size.text()))
    

    def DDS2_new_Vpp_stepBy(self, steps):
        self.DDS2_old_Vpp_stepBy(steps)
        self.DDS2_Vpp_updated()
        
    def DDS2_Vpp_editing_finished(self):
        self.DDS2_Vpp_updated()

    def DDS2_Vpp_updated(self):
        #print('Vpp', self.DDS2_Vpp_spinbox.value())
        
        Vamp=self.DDS2_Vpp_spinbox.value()/2
        mW=10*Vamp**2
        if mW > 0:
            dBm = 10*math.log10(mW)
        else:
            dBm = -1000
        self.DDS2_mW_spinbox.setValue(mW)
        self.DDS2_dBm_spinbox.setValue(dBm)
        
        if self.DDS2_auto_power_apply_checkbox.isChecked():
            self.DDS2_apply_power()

    def DDS2_Vpp_step_size_changed(self):
        self.DDS2_Vpp_spinbox.setSingleStep(float(self.DDS2_Vpp_step_size.text()))



    def DDS2_new_mW_stepBy(self, steps):
        self.DDS2_old_mW_stepBy(steps)
        self.DDS2_mW_updated()
        
    def DDS2_mW_editing_finished(self):
        self.DDS2_mW_updated()

    def DDS2_mW_updated(self):
        #print('mW', self.DDS2_mW_spinbox.value())

        mW = self.DDS2_mW_spinbox.value()
        Vamp = math.sqrt(mW/10)
        if mW > 0:
            dBm = 10*math.log10(mW)
        else:
            dBm = -1000
        self.DDS2_Vpp_spinbox.setValue(2*Vamp)
        self.DDS2_dBm_spinbox.setValue(dBm)
        
        if self.DDS2_auto_power_apply_checkbox.isChecked():
            self.DDS2_apply_power()

    def DDS2_mW_step_size_changed(self):
        self.DDS2_mW_spinbox.setSingleStep(float(self.DDS2_mW_step_size.text()))


    def DDS2_set_power_mW(self, mW):
        self.DDS2_mW_spinbox.setValue(mW)
        Vamp = math.sqrt(mW/10)
        if mW > 0:
            dBm = 10*math.log10(mW)
        else:
            dBm = -1000
        self.DDS2_Vpp_spinbox.setValue(2*Vamp)
        self.DDS2_dBm_spinbox.setValue(dBm)
        
        self.DDS2_apply_power()
        
        
    def DDS2_set_freq_Hz(self, Hz):
        DDS2_freq_unit_index = self.DDS2_freq_unit.currentIndex()
        scale = 10**(3*DDS2_freq_unit_index)
        
        self.DDS2_freq_spinbox.setValue(Hz/scale)
        self.DDS2_apply_freq()


    def DDS2_new_dBm_stepBy(self, steps):
        self.DDS2_old_dBm_stepBy(steps)
        self.DDS2_dBm_updated()
        
    def DDS2_dBm_editing_finished(self):
        self.DDS2_dBm_updated()

    def DDS2_dBm_updated(self):
        #print('dBm', self.DDS2_dBm_spinbox.value())

        dBm = self.DDS2_dBm_spinbox.value()
        mW = 10**(dBm/10)
        Vamp = math.sqrt(mW/10)
        self.DDS2_mW_spinbox.setValue(mW)
        self.DDS2_Vpp_spinbox.setValue(2*Vamp)
        
        if self.DDS2_auto_power_apply_checkbox.isChecked():
            self.DDS2_apply_power()


    def DDS2_dBm_step_size_changed(self):
        self.DDS2_dBm_spinbox.setSingleStep(float(self.DDS2_dBm_step_size.text()))


    def DDS2_trigger_on_off(self):
        if self.DDS2_trigger_on:
            self.write('DDS2:TRIG False')
            self.DDS2_trigger_button.setIcon(self.off_icon)
            self.DDS2_trigger_on = False
        else:
            self.write('DDS2:TRIG True')
            self.DDS2_trigger_button.setIcon(self.on_icon)
            self.DDS2_trigger_on = True
            
    

        
if __name__ == "__main__":
    app = QtWidgets.QApplication.instance()
    if app is None:
        app = QtWidgets.QApplication([])
    
    dds_dac = DDS_DAC()
    dds_dac.show()
    app.exec_()
    #sys.exit(app.exec_())

