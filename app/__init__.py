from flask import Flask
from config import Config
from flask import render_template, flash, request, redirect, url_for, Blueprint


app = Flask(__name__)
from app import routes

app.config.from_object(Config)
