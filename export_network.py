#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 29 16:49:26 2018

@author: tolga
"""

#import collections
import time
import numpy as np
import tensorflow as tf

from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("MNIST_data/")

test_data_provider = mnist.test

from networks import network_dense
from networks import network_sparse
from configs import ConfigNetworkDensePruned as config_pruned
from configs import ConfigNetworkSparse as config_sparse
from utils import plot_utils
from utils import pruning_utils

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

#weight_matrices, bias_vectors = classifier.sess.run([classifier.weight_matrices, 
 #                                                    classifier.biases])
            
#classifier.export = export
classifier.export('test.txt','verilog')
with open('test.txt','r') as f:
    a = f.read()