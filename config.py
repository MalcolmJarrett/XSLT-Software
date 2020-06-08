import os

app_dir = os.path.abspath(os.path.dirname(__file__))

class BaseConfig:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'youratsayasaurus'
    UPLOAD_FOLDER = "/tmp/"
    # app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

class DevelopmentConfig(BaseConfig):
    DEBUG = True

class TestConfig(BaseConfig):
    DEBUG = True

class ProductionConfig(BaseConfig):
    DEBUG = False
