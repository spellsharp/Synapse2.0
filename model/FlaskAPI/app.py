from flask import Flask, request, render_template, send_file
import os

app = Flask(__name__)

def modify_video(video_path):
    modified_video_path = "public/send/modified_video.mp4"
    os.system(f'cp {video_path} {modified_video_path}')
    return modified_video_path

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/video', methods=['POST'])
def video():
    if request.method == 'POST':
        uploaded_video = request.files['video']
        save_directory = "public/receive/"
        new_video_name = 'video.mp4'
        
        uploaded_video.save(os.path.join(save_directory, new_video_name))
        modified_video_path = modify_video(os.path.join(save_directory, new_video_name))
        
        uploaded_video.close()
        
        return send_file(modified_video_path, as_attachment=True)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)