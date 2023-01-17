
 add_fsm_encoding \
       {async_receiver.state} \
       { }  \
       {{0000 0000000001} {0001 1000000000} {1000 0000000010} {1001 0000000100} {1010 0000001000} {1011 0000010000} {1100 0000100000} {1101 0001000000} {1110 0010000000} {1111 0100000000} }

 add_fsm_encoding \
       {data_receiver.escape_state} \
       { }  \
       {{0000 000001} {0001 000010} {0010 000100} {0011 001000} {0100 100000} {0101 010000} }

 add_fsm_encoding \
       {data_receiver.main_state} \
       { }  \
       {{0000 000000000000010} {0001 000000000000100} {0010 000000000001000} {0011 000000000010000} {0100 000000000100000} {0101 000000001000000} {0110 000000010000000} {0111 000000100000000} {1000 000001000000000} {1001 000010000000000} {1010 000100000000000} {1011 001000000000000} {1100 000000000000001} {1101 100000000000000} {1110 010000000000000} }

 add_fsm_encoding \
       {async_transmitter.state} \
       { }  \
       {{0000 0000000000001} {0001 0000000000010} {0010 0100000000000} {0011 1000000000000} {0100 0000000000100} {1000 0000000001000} {1001 0000000010000} {1010 0000000100000} {1011 0000001000000} {1100 0000010000000} {1101 0000100000000} {1110 0001000000000} {1111 0010000000000} }

 add_fsm_encoding \
       {data_sender.main_state} \
       { }  \
       {{000000 0000000001} {000001 0000000010} {000100 0000100000} {000101 0000001000} {000110 0000010000} {001000 0001000000} {001001 0010000000} {001010 0100000000} {010000 1000000000} {010001 0000000100} }

 add_fsm_encoding \
       {data_sender.transmitter_state} \
       { }  \
       {{0000 0001} {0001 0010} {0010 0100} {1111 1000} }

 add_fsm_encoding \
       {spi_fsm_module.spi_fsm_state} \
       { }  \
       {{000 0000001} {001 0000100} {010 1000000} {011 0100000} {100 0001000} {101 0010000} {110 0000010} }

 add_fsm_encoding \
       {device_DNA.state} \
       { }  \
       {{0000 0001} {0001 0010} {0010 0100} {0011 1000} }

 add_fsm_encoding \
       {main.main_state} \
       { }  \
       {{0000 00000000001} {0001 00000000010} {0010 00000000100} {0111 00000100000} {1000 00001000000} {1010 00010000000} {1011 00100000000} {1100 01000000000} {1101 00000001000} {1110 00000010000} {1111 10000000000} }
