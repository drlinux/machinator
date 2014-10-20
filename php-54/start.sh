#!/bin/bash
docker run -d  -i --name="machinator-DOMAIN" -p PORT:80 -v ROOT:/var/www/DOMAIN -t machinator/DOMAIN
