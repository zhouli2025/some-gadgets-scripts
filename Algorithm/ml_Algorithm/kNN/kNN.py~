#-*- coding:utf-8 -*-
from numpy import *
import operator
from os import listdir

def createDataSet():
    group = array([[1.0, 1.1], [1.0, 1.0], [0, 0], [0, 0.1]])
    labels = ['A', 'A', 'B', 'B']
    return group,labels

def classify0(inX, dataSet, labels, k): #inX: 要分类的变量 dataSet:训练样本集 labels：训练样本对应的标签 k：选择最近邻居的数目
    dataSetSize = dataSet.shape[0]  # 矩阵的行数
    diffMat = tile(inX, (dataSetSize,1)) - dataSet #重复inX, create a new matrix in form of (dataSetSize,1)
    sqDiffMat = diffMat**2 #对矩阵每个元素做平方运算 幂运算针对都是element-wise

    sqDistances = sqDiffMat.sum(axis=1)  #将一个矩阵的每一行向量相加
    distances = sqDistances**0.5 #得到 对应训练数据集中顺序排列的每个点的距离
    sortedDistIndicies = distances.argsort() #数组保持原序,得到由小到大排列的索引号
    classCount={} #字典，每个类别对应键值即为投票数
    for i in range(k):  #进行k次迭代，将最近的k个邻居遍历
        voteIlabel = labels[sortedDistIndicies[i]] #依次得到最近的k个点的类别
        classCount[voteIlabel] = classCount.get(voteIlabel,0) + 1 #返回voteIlabel的键值，为空时返回0
    sortedClassCount = sorted(classCount.items(), key=operator.itemgetter(1), reverse=True)
    # dict中 items() 函数以列表返回可遍历的(键, 值) 元组数组
    # key = operator.itemgetter(1) 定义函数key，获取对象的第1个域的值
    return sortedClassCount[0][0]


def file2matrix(filename):
    fr = open(filename)
    arrayOLines = fr.readlines()
    numberOfLines = len(arrayOLines)
    returnMat = zeros((numberOfLines,3))
    classLabelVector = []
    index = 0
    for line in arrayOLines:
        line = line.strip()
        listFromLine = line.split('\t')
        returnMat[index,:] = listFromLine[0:3]
        classLabelVector.append(int(listFromLine[-1]))
        index += 1
    # classLabelVector= np.array(classLabelVector)
    return returnMat,classLabelVector


def autoNorm(dataSet):
    minVals = dataSet.min(0) # 机智地取了当前{列}的最小值
    maxVals = dataSet.max(0)
    ranges = maxVals - minVals
    normDataSet = zeros(shape(dataSet))
    m = dataSet.shape[0]
    normDataSet = dataSet - tile(minVals, (m, 1))
    normDataSet = normDataSet/tile(ranges,(m,1))  # 具体特征值相除,矩阵相除用linalg.solve()
    return normDataSet, ranges, minVals

def img2vector(filename):
    returnVect = zeros((1, 1024)) # 二维数组
    fr = open(filename)
    for i in range(32):
        lineStr = fr.readline()  # 读32行
        for j in range(32):
            returnVect[0,32*i+j] = int(lineStr[j])
    return returnVect

def handwritingClassTest():
    hwLabels = []
    trainingFileList = listdir('trainingDigits')
    m = len(trainingFileList)
    trainingMat = zeros((m,1024))
    for i in range(m):
        fileNameStr = trainingFileList[i]
        fileStr = fileNameStr.split('.')[0]
        classNumStr = int(fileStr.split('_')[0])
        hwLabels.append(classNumStr)
        trainingMat[i,:] = img2vector('trainingDigits/%s' % fileNameStr)
    testFileList = listdir('testDigits')
    errorCount = 0.0
    mTest = len(testFileList)
    for i in range(mTest):
        fileNameStr = testFileList[i]
        fileStr = fileNameStr.split('.')[0]
        classNumStr = int(fileStr.split('_')[0])
        vectorUnderTest = img2vector('testDigits/%s' % fileNameStr)
        classifierResult = classify0(vectorUnderTest, trainingMat, hwLabels, 3)

        print("the classifier came back with: %d, the real answer is: %d" %(classifierResult, classNumStr))
        if (classifierResult != classNumStr):
            errorCount += 1.0

        print("the total number of errors is: %d" % errorCount)
        print("the total error rate is: %f" % (errorCount/float(mTest)))
