sass frontend/sass/comments.scss > demo/main.css
cd frontend
nim js main
cp nimcache/main.js ../demo/
cd ../backend
nim c main
