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
- [ ] Adder.
- [ ] Test bench that reads txt.
- [ ] Connect input_fifo, input memory and multiplier (multiplication stage)
- [ ] Connect output of multiplier to adder and output memory (accumulation stage)
- [ ] Data Exporting in fixed point for verilog.
- [ ] Controller.
- [ ] Accumulation stage.


## Documentation:
- [X] Histograms, and time measurements.
- [X] Histograms for quantization.
- [X] Pruning Methods.
- [X] Quantization methods.
- [X] Sample thesis start.
- [ ] Explain Fixed point.
- [ ] Explain run lenght encoding.
- [ ] Do tests for 3 datasets for 3 networks (train, prune, quantize, encode).
- [ ] Draw nnEngine Architecture.
- [ ] Explain modules.
- [ ] Explain architecture.
- [ ] Do some estimations about speed up and energy efficiency.
