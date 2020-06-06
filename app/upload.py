'''
This is the uploader function for the app.
'''

# Variables set for the upload file function
UPLOAD_FOLDER = "/tmp/"
ALLOWED_EXTENSIONS = "pptx"
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# upload form function
def allowed_file(filename):
    return '.' in filename and \ filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# when the page has been submitted
@app.route('/upload', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        # Check if the post request has a file part
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        file = request.files['file']
        # if there's no file selected, or submitted with an empty part without a filename
        if file.filename == '':
            flash('No file selected')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            flash('File uploaded')

    # This waits until it can see the file exists in the temp folder before returning the results.
    while not os.path.exists(UPLOAD_FOLDER + filename):
        time.sleep(2)

    return redirect(url_for('results', filename=filename))
