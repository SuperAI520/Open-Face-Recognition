# OpenFace training tests.
#
# Copyright 2015 Carnegie Mellon University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import os
import shutil

import numpy as np
np.set_printoptions(precision=2)
import pandas as pd
import scipy
import scipy.spatial
import tempfile

from subprocess import Popen, PIPE

openfaceDir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
modelDir = os.path.join(openfaceDir, 'models')

exampleImages = os.path.join(openfaceDir, 'images', 'examples')
lfwSubset = os.path.join(openfaceDir, 'data', 'lfw-subset')



def test_dnn_training():
    # Get lfw-subset by running ./data/download-lfw-subset.sh
    assert os.path.isdir(lfwSubset)

    cmd = ['python2', os.path.join(openfaceDir, 'util', 'align-dlib.py'),
           os.path.join(lfwSubset, 'raw'), 'align', 'outerEyesAndNose',
           os.path.join(lfwSubset, 'aligned', 'train')]
    p = Popen(cmd, stdout=PIPE, stderr=PIPE)
    (out, err) = p.communicate()
    assert p.returncode == 0

    workDir = tempfile.mkdtemp(prefix='OpenFaceTrainingTest-')
    cmd = ['th', './main.lua',
           '-data', os.path.join(lfwSubset, 'aligned'),
           '-modelDef', '../models/openface/nn4.def.lua',
           '-peoplePerBatch', '3',
           '-imagesPerPerson' , '4',
           '-nEpochs', '10',
           '-epochSize', '5',
           '-testEpochSize', '0',
           '-cache', workDir,
           '-cuda', '-cudnn',
           '-nDonkeys', '-1']
    p = Popen(cmd, stdout=PIPE, stderr=PIPE, cwd=os.path.join(openfaceDir, 'training'))
    (out, err) = p.communicate()
    # print(out)
    # print(err)
    assert p.returncode == 0

    # Training won't make much progress on lfw-subset, but as a sanity check,
    # make sure the training code runs and doesn't get worse than the initialize
    # loss value of 0.2.
    trainLoss = pd.read_csv(os.path.join(workDir, '1', 'train.log'),
                            sep='\t').as_matrix()[:, 0]
    assert trainLoss[-1] < 0.25

    shutil.rmtree(os.path.join(lfwSubset, 'aligned'))
    shutil.rmtree(workDir)
