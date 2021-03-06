from flask import Flask, render_template, jsonify, request, Response
from PIL import Image, ImageOps
from io import BytesIO
# from sklearn.externals import joblib
import pickle
import json
import pickle
import numpy as np
import requests
from keras.models import load_model
from keras.preprocessing import image
from keras import backend as K
import os
from importlib import reload


# These are the possible categories (classes) which can be detected
namemap = [
    'axes',
    'boots',
    'carabiners',
    'crampons',
    'gloves',
    'hardshell_jackets',
    'harnesses',
    'helmets',
    'insulated_jackets',
    'pulleys',
    'rope',
    'tents'
]
cato = {0: 'axes', 1: 'boots', 2: 'carabiners', 3: 'crampons', 4: 'gloves', 5: 'hardshell_jackets',
        6: 'harnesses', 7: 'helmets', 8: 'insulated_jackets', 9: 'pulleys', 10: 'rope', 11: 'tents'}

app = Flask(__name__)

def set_keras_backend(backend):
    if K.backend() != backend: 
        os.environ['KERAS_BACKEND'] = backend
        reload(K)
        assert K.backend() == backend
        

def resize(image):
    """ Resize any image to 128 x 128, which is what the model has been trained on """

    base = 64
    width, height = image.size

    if width > height:
        wpercent = base/float(width)
        hsize = int((float(height) * float(wpercent)))
        image = image.resize((base, hsize), Image.ANTIALIAS)
    else:
        hpercent = base/float(height)
        wsize = int((float(width) * float(hpercent)))
        image = image.resize((wsize, base), Image.ANTIALIAS)

    newImage = Image.new('RGB',
                         (base, base),     # A4 at 72dpi
                         (255, 255, 255))  # White

    position = (int((base/2 - image.width/2)), 0)
    newImage.paste(image, position)

    return newImage


def normalize(arr):
    """ This means that the largest value for each attribute is 1 and the smallest value is 0.
        Normalization is a good technique to use when you do not know the distribution of your data 
        or when you know the distribution is not Gaussian (a bell curve)."""

    arr = arr.astype('float')

    # Do not touch the alpha channel
    for i in range(3):
        minval = arr[..., i].min()
        maxval = arr[..., i].max()
        if minval != maxval:
            arr[..., i] -= minval
            arr[..., i] *= (255.0/(maxval-minval))

    return arr


def processImage(image):
    """ Resize and normalize the image """

    image = resize(image)
    arr = np.array(image)
    new_img = Image.fromarray(normalize(arr).astype('uint8'), 'RGB')

    return new_img


def what_is_it(url):
    global Image
    testImageUrl = url
    response = requests.get(testImageUrl)
    testImage = Image.open(BytesIO(response.content))

    from PIL import Image
    r = requests.get(testImageUrl)
    b = BytesIO(r.content)

    test_image = image.load_img(b, target_size=(64, 64))
    test_image = image.img_to_array(test_image)
    test_image = np.expand_dims(test_image, axis=0)
    
    classifier = load_model('my_model.h5')

    result = classifier.predict(test_image)
    print(result, cato[result.argmax()])
    return cato[result.argmax()]


@app.route('/predict', methods=['POST'])
def predict():
    try:
        body = request.get_json()
        img_url = body["url"]

        prediction = what_is_it(img_url)
        print(prediction)
        response = json.dumps({"classification": prediction})
        return response
    except Exception as e:
        print(e)
        raise


@app.route('/classify', methods=['POST'])
def classify():
    """ Make a POST to this endpint and pass in an URL to an image in the body of the request.
        Swap out the model.pkl with another trained model to classify new objects. """

    try:
        body = request.get_json()
        print(body)
        img_url = body["url"]

        # Get the image and show it
        response = requests.get(img_url)
        img = Image.open(BytesIO(response.content))
        prcedImg = processImage(img)

        # Convert a 2D image into a flat array
        # imgFeatures = np.array(prcedImg).ravel().reshape(1,-1)
        imgFeatures = np.array(prcedImg)
        imgFeatures = np.expand_dims(imgFeatures, axis=0)
        print(imgFeatures)

        model   = joblib.load('pickle_model.pkl')
        # model = load_model('my_model.h5')
        predict = model.predict(imgFeatures)
        print('The image is a ', namemap[int(predict[0])]),

        print('image: ', namemap[int(predict[0])], predict)

        # Convert the integer returned from the model into the name of the class from our namemap above.
        # EX: 0 = axes, 1 = boots, 2 = carabiners
        response = json.dumps({"classification": namemap[int(predict[0])]})
        return(response)

    except Exception as e:
        print(e)
        raise


if __name__ == '__main__':
    set_keras_backend("cntk")
    app.run(debug=True, host='0.0.0.0')
