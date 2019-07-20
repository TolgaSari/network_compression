import collections

import numpy as np

def prune_weights(weights, pruning_threshold):

    small_weights = np.abs(weights) < pruning_threshold
    weights[small_weights] = 0
    values = weights[weights != 0]
    indices = np.transpose(np.nonzero(weights))
    return values, indices

def get_sparse_values_indices(weights):

    values = weights[weights != 0]
    indices = np.transpose(np.nonzero(weights))
    return values, indices

def mask_for_big_values(weights, pruning_threshold):

    small_weights = np.abs(weights) < pruning_threshold
    return np.logical_not(small_weights)

def calculate_number_of_sparse_parameters(sparse_layers):

    total_count = 0

    for layer in sparse_layers:

        total_count += layer.values.nbytes // 4
        total_count += layer.indices.nbytes // 4
        total_count += layer.dense_shape.nbytes // 4
        total_count += layer.bias.nbytes // 4

    return total_count

class SparseLayer(collections.namedtuple('SparseLayer',
                                         ['values',
                                          'indices',
                                          'dense_shape',
                                          'bias'])):

    """An auxilary class to represent sparse layer"""
    pass

def quantify(values,fixLoc,interval=0.25):
    # A naive linear quantizier
    
    halfFix = fixLoc
    neg_bins = np.array([-x/(2**halfFix)*interval for x in reversed(range(2**halfFix))])[:-1]
    pos_bins = np.array([x/(2**halfFix)*interval for x in range(2**halfFix)])
    bins = np.concatenate((neg_bins, pos_bins))
    centers = (bins[1:]+bins[:-1])/2
    
    quantified = np.digitize(values, centers)
    
    res = bins[quantified]
    return res.astype(np.float32), (quantified - 2**(fixLoc) + 1)

def export_quantized(filename, fixLoc, interval, weight_matrices, bias_vectors):

        paramCount = 0
        neg_bins = np.array([-x/(2**fixLoc)*interval for x in reversed(range(2**fixLoc))])[:-1]
        pos_bins = np.array([x/(2**fixLoc)*interval for x in range(2**fixLoc)])
        bins = np.concatenate((neg_bins, pos_bins))
        print(bins)
        
        with open(filename, "w") as file:
            #file.write(str(fixLoc) + '\n')            
            file.write(str(len(weight_matrices)) + '\n')
            for i in weight_matrices:
                for j in i.shape:
                    file.write(str(j) + '\n')
            for weights, biases in zip(weight_matrices, bias_vectors):
                for i in biases.transpose().flatten():
                    paramCount += 1
                    file.write(str(i) + '\n')
                for i in weights.flatten():
                    paramCount += 1
                    file.write(str(i) + '\n')
        
        with open("aprox_" + filename, "w") as file:
            #file.write(str(fixLoc) + '\n')            
            file.write(str(len(weight_matrices)) + '\n')
            for i in weight_matrices:
                for j in i.shape:
                    file.write(str(j) + '\n')
            for weights, biases in zip(weight_matrices, bias_vectors):
                for i in biases.transpose().flatten():
                    paramCount += 1
                    file.write(str(i*2**(-fixLoc)*0.25) + '\n')
                for i in weights.flatten():
                    paramCount += 1
                    file.write(str(i*2**(-fixLoc)*0.25) + '\n')
                    
def cifar10toMnist(mnist):
    from keras.datasets import cifar10
    
    (x_train, y_train), (x_test, y_test) = cifar10.load_data()
    
    temp = imageReshape(x_train)
    
    mnist.train._images = temp[0:40000]
    mnist.train._labels = y_train[0:40000].flatten()
    mnist.train._num_examples = 40000
    
    mnist.validation._images = temp[40000:]
    mnist.validation._labels = y_train[40000:].flatten()
    mnist.validation._num_examples = 10000
    
    mnist.test._images = imageReshape(x_test)
    mnist.test._labels = y_test.flatten()
    mnist.test._num_examples = 10000
    
    return mnist
    
def imageReshape(imageList,):
    temp = imageList.reshape(imageList.shape[0],1024,3)
    temp = temp.reshape(imageList.shape[0],3072).astype(np.float32)/256
    
    return temp

def export_sparse_packets(sparse_layers):
    for i in range(len(sparse_layers)):
        with open("sparse_network/sparse_layer_" + str(i), "w") as f:
            for j in range(len(sparse_layers[i][0])):
                value = sparse_layers[i][0][j]
                row = sparse_layers[i][1][j][0]
                col = sparse_layers[i][1][j][1]
                value = (value & 255) << 24
                row = row << 12
                packet = value | row | col
                f.write(hex(packet)[2:] + "\n") # use hex(packet) to check
                
        with open("sparse_network/sparse_bias_" + str(i), "w") as f:
            for j in range(len(sparse_layers[i][3])):
                f.write(str(sparse_layers[i][3][j]) + "\n")  
                
        with open("sparse_network/sparse_shape_" + str(i), "w") as f:
            for j in range(len(sparse_layers[i][2])):
                f.write(str(sparse_layers[i][2][j]) + "\n")  
