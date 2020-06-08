import os
from http import cookies

from flask import Flask
from flask import render_template, flash, request, redirect, url_for, Blueprint

def create_app(test_config=None):
    # Create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        SECRET_KEY='dev',
    )
    UPLOAD_FOLDER = "/tmp/"
    app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

    if test_config is None:
        #Load the instance config, if it exists, when not testing
        app.config.from_pyfile('config.py', silent=True)
    else:
        #Load the test config if passed in
        app.config.from_mapping(test_config)

    #ensure instance folder
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    # Launch the app with the homepage
    @app.route('/')
    def index():
        return render_template("index.html")

    from . import forms
    app.register_blueprint(forms.bp)

    from . import pptxTranslator
    app.register_blueprint(pptxTranslator.bp)

    return app
