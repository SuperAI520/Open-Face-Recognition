# Demo 1: Real-Time Web Demo
See [our YouTube video](https://www.youtube.com/watch?v=LZJOTRkjZA4)
of using this in a real-time web application
for face recognition.
The source is available in
[demos/web](https://github.com/cmusatyalab/openface/blob/master/demos/web).
The browser portions have been tested on Google Chrome 46 in OSX.

<a href='https://www.youtube.com/watch?v=LZJOTRkjZA4'><img src='https://raw.githubusercontent.com/cmusatyalab/openface/master/images/youtube-web.gif'></img></a>

This demo does the full face recognition pipeline on every frame.
In practice, object tracking
[like dlib's](http://blog.dlib.net/2015/02/dlib-1813-released.html)
should be used once the face recognizer has predicted a face.

In the edge case when a single person is trained,
the classifier has no knowledge of other people and
labels anybody with the name of the trained person.

The web demo does not predict unknown users.
If you're interested in predicting unknown people,
one idea is to use a probabilistic classifier to predict
confidence scores and then call the prediction unknown
if the confidence is too low.
See the [classification demo](http://cmusatyalab.github.io/openface/demo-3-classifier/)
for an example of using a probabilistic classifier.

---

## Setup

To run on your system, first follow the
[Setup Guide](setup.md) and make sure you can
run a simpler demo, like the [comparison demo](demo-2-comparison.md).

Next, install the requirements for the web demo with
`./install-deps.sh` and `sudo pip install -r requirements.txt`
from the `demos/web` directory.
This is currently not included in the Docker container.
The application is split into a processing server and static
web pages that communicate via web sockets.

Start the HTTP and WebSocket servers on ports 8000 and 9000, respectively,
with `./demos/web/start-servers.sh`.
If you wish to use other ports,
pass them as `./demos/web/start-servers.sh HTTP_PORT WEBSOCKET_PART`.
You should now be able to send a request to the websocket
connection with `curl your-server:9000` (`localhost:9000` if running on your machine),
which should inform you that it's' a WebSocket endpoint and not a web server.
Please check routing between your client and server if you
get connection refused issues.
You should now also be able to access the demo from your browser
at `http://your-server:8000`.
The saved faces are only available for the browser session.

If you experience issues running these commands,
please post the WebSocket log contents from `/tmp/openface.websocket.log`
to [our mailing list](https://groups.google.com/forum/#!forum/cmu-openface).
