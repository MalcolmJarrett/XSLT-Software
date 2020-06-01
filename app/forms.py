from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField, FileField
from wtforms.validators import DataRequired

class UploadForm(FlaskForm):
    file = FileField()
    submit = SubmitField('Upload')
