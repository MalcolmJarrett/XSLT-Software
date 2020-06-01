from flask import Blueprint

scraper = Blueprint('scraper', __name__)
@scraper.route('/scrape')
def scraper():
    return "This is a scraper app"
