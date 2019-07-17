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
#pruning_utils.cifar10toMnist(mnist)
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

# restore a model
classifier.load_model()


weight_matrices, biases = classifier.sess.run([classifier.weight_matrices,
                                               classifier.biases])
q_sparse_layers = []
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
    
    qvalues, qindices = pruning_utils.get_sparse_values_indices(q_weights)
    shape = np.array(weights.shape).astype(np.int64)
    
    q_sparse_layers.append(pruning_utils.SparseLayer(values=qvalues.astype(np.int32),
                                                   indices=qindices.astype(np.int32),
                                                   dense_shape=shape,
                                                   bias=q_biases))

pruning_utils.export_sparse_packets(q_sparse_layers)
#pruning_utils.export_quantized("qweights.txt", 3, 0.25, qlayers, qbiases)
# create sparse classifier