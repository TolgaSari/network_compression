# Network pruning

## Project flow:

- [X] Compression for small network.
- [X] Naive linear quantization to fixed size in float format.
- [X] Weight exporting. (In float form)
- [X] Image exporting. (In float form)
- [X] Label exporting.
- [X] Data importing in C. (In float form)
- [X] Layer pass. (In float form)
- [X] Forward pass. (In python)
- [X] Forward pass implementation. (In float form)
- [X] Data Exporting. (quantized) (you quantize sparse model but export dense)
- [X] Run Lenght Encodeing.
- [X] Input FIFO.
- [X] Single Port Ram.
- [X] Memory Switch.
- [X] Multiplicator.
- [X] Proper greedy quantization for fixed point. 
- [X] Test bench that reads txt.
- [ ] Add fetch memory stage.
- [X] Make Multiplication stage.
- [ ] Test Multiplication stage.
- [ ] Add ReLu comparator switch to input of multiplication stage
- [ ] Connect output of multiplier to adder and output memory (accumulation stage)
- [X] Data Exporting in packets verilog. (make hex dump to not write 0x)
- [ ] Controller.
- [ ] Switch memories.
- [ ] Read inputs to first memory.
- [ ] Read Bias to second memory.
- [ ] Accumulation stage.


## Documentation:
- [X] Histograms, and time measurements.
- [X] Histograms for quantization.
- [X] Pruning Methods.
- [X] Quantization methods.
- [X] Sample thesis start.
- [X] Explain Fixed point.
- [X] Explain run lenght encoding.
- [ ] Do tests for 3 datasets for 3 networks (train, prune, quantize, encode).
- [X] Draw nnEngine Architecture.
- [ ] Explain modules.
- [X] Explain architecture.
- [ ] Do some estimations about speed up and energy efficiency.
