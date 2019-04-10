Untuk membuat image dengan
- Nginx
- PHP5.3 & PHP-FPM nya
- InstantClient 11.2
- Oci8

1. download semuanya dan taruh ke 1 folder
2. docker build -t app-php53:instantcli11_2-nginx .  <--- janganlupa ada titiknya
3. kalau sudah selesai bisa di run imagenya menjadi sebuah container dengan:

docker run -d --name <nama_container> -p <port_host>:80 -p <port_host>:9053 <nama_image>

docker run -d --name odi -p 80:80 -p 9053:9053 app-php53:instantcli11_2-nginx


4. kalau ingin masuk ke containernya untuk di setting2 lagi bisa dengan:

docker exec -it <nama_container> bash

docker exec -it odi bash
