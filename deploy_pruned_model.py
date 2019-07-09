#import collections
import time
import numpy as np
import tensorflow as tf

from networks import network_dense
from networks import network_sparse
from configs import ConfigNetworkDensePruned as config_pruned
from configs import ConfigNetworkSparse as config_sparse
from utils import plot_utils
from utils import pruning_utils

from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("MNIST_data/")
#mnist = input_data.read_data_sets("FASHION_MNIST_data/")
pruning_utils.cifar10toMnist(mnist)
test_data_provider = mnist.test



# create pruned classifier
classifier = network_dense.FullyConnectedClassifier(
                            input_size=config_pruned.input_size,
                            n_classes=config_pruned.n_classes,
                            layer_sizes=config_pruned.layer_sizes,
                            model_path=config_pruned.model_path,
                            dropout=config_pruned.dropout,
                            weight_decay=config_pruned.weight_decay,
                            activation_fn=config_pruned.activation_fn,
                            pruning_threshold=config_pruned.pruning_threshold)

q_classifier = network_dense.FullyConnectedClassifier(
                            input_size=config_pruned.input_size,
                            n_classes=config_pruned.n_classes,
                            layer_sizes=config_pruned.layer_sizes,
                            model_path=config_pruned.q_model_path,
                            dropout=config_pruned.dropout,
                            weight_decay=config_pruned.weight_decay,
                            activation_fn=config_pruned.activation_fn,
                            pruning_threshold=config_pruned.pruning_threshold)
# restore a model
classifier.load_model()
runtime = time.time()
accuracy, loss = classifier.evaluate(data_provider=test_data_provider,
                                     batch_size=config_sparse.batch_size)
runtime = time.time() - runtime
print('Dense model took ', runtime, 'seconds to evaluate.')
print('Accuracy on test with dense model (pruned): {accuracy}, loss on test: {loss}'.format(
                                                   accuracy=accuracy, loss=loss))

weight_matrices, biases = classifier.sess.run([classifier.weight_matrices,
                                               classifier.biases])
sparse_layers = []
layers = []
qlayers = []
qbiases = []
fixLoc = 3

# turn dense pruned weights into sparse indices and values
for weights, bias in zip(weight_matrices, biases):

    weights, q_weights = pruning_utils.quantify(weights,fixLoc)
    bias, q_biases = pruning_utils.quantify(bias,fixLoc)
    
    layers.append(weights)
    qlayers.append(q_weights)
    qbiases.append(q_biases)
    
    values, indices = pruning_utils.get_sparse_values_indices(weights)
    shape = np.array(weights.shape).astype(np.int64)
    sparse_layers.append(pruning_utils.SparseLayer(values=values.astype(np.float32),
                                                   #values=values.astype(np.int8),
                                                   indices=indices.astype(np.int16),
                                                   dense_shape=shape,
                                                   bias=bias))

pruning_utils.export_quantized("qweights.txt", 3, 0.25, qlayers, qbiases)
# create sparse classifier
sparse_classifier = network_sparse.FullyConnectedClassifierSparse(
                            input_size=config_sparse.input_size,
                            n_classes=config_sparse.n_classes,
                            sparse_layers=sparse_layers,
                            model_path=config_sparse.model_path,
                            activation_fn=config_sparse.activation_fn)

# test sparse classifiergt
runtime = time.time()
accuracy, loss = sparse_classifier.evaluate(data_provider=test_data_provider,
                                            batch_size=config_sparse.batch_size)
runtime = time.time() - runtime
print('Sparse network took', runtime,' seconds to evaluate.')
print('Accuracy on test with sparse model: {accuracy}, loss on test: {loss}'.format(
                                                   accuracy=accuracy, loss=loss))

compRatio = (classifier.params-sparse_classifier.params)/classifier.params*100
print('Compression ratio = ', 100/(100 - compRatio))
print('Compression ratio including quantization = ', 100/(100 - compRatio)*32/(fixLoc+1))

plot_utils.plot_histogram(layers,
                          'weights_distribution_after_quantization',
                          include_zeros=False)

# finally, save a sparse model
sparse_classifier.save_model()
