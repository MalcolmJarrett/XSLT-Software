import os, config
from http import cookies
from flask import Flask, render_template, flash, request, redirect, url_for, Blueprint

def create_app():
    # Create and configure the app
    app = Flask(__name__)

    # This config provides settings and variables that should be accessible throughout the app.
    app.config.from_pyfile('config.py', silent=True)

    # Launch the app with the homepage
    @app.route('/')
    def index():
        return render_template("index.html")

    # Blueprints for where the apps functions live.
    from . import forms
    app.register_blueprint(forms.bp)

    from . import pptxTranslator
    app.register_blueprint(pptxTranslator.bp)

    # Start the app
    return app
