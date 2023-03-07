import geoip2.database


def get_geoip(ip):
    geodata = {}
    geoip = {}
    geoip["location"] = {}
    with geoip2.database.Reader("GeoLite2/GeoLite2-City.mmdb") as reader:
        try:
            response = reader.city(ip)
            geoip["country"] = response.country.name
            geoip["city"] = response.city.name
            geoip["location"]["lat"] = response.location.latitude
            geoip["location"]["lon"] = response.location.longitude
            geodata["geoip"] = geoip
            return geodata
        except:
            geoip["country"] = None
            geoip["city"] = None
            geoip["location"]["lat"] = None
            geoip["location"]["lon"] = None
            geodata["geoip"] = geoip
            return geodata


# 203.0.113.9
# geoip = get_geoip("203.0.113.9")
