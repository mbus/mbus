Implementation Documentation
============================

This documentation contains details of the M3 MBus implmentation.

The authoritative source for the MBus Specification is http://mbus.io


Errata
------

 - The Bus Controller exposes a word-interface, however MBus allows for
   byte-granularity transactions.
   - This implementation will correctly interface (ACK short transactions),
     however it will propogate stale data for the remaining bytes in the
     last received "word".
   - The bus controller will only transmit full words.

