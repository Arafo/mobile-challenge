#!/usr/bin/python

# import libraries
import requests
import urllib2
from bs4 import BeautifulSoup
from selenium import webdriver

# url and headers
link = "https://www.adidas.es/calzado?sz=120&start=" 
hdr = {'User-Agent': 'Mozilla/5.0'}
domains = ["es"]
pagging = 120
totalItems = 0
products = []

def scraper(url, total):
    items = 0
    driver.get(url)
    results = driver.find_elements_by_xpath('//div[@class="image plp-image-bg"]/a')
    for result in results:
        productLink = result.get_attribute('href')
        products.append(productLink)
        print result.get_attribute('href')
        items = items + 1

    total = total + items
    newLink = link + str(total)
    print newLink + "\n"
    print items
    
    if items == 0:
        scraper(newLink, total)

def scrapProducts():
    for product in products:
        driver.get(product)
        model = driver.find_elements_by_xpath('//h1[@id="product-title"]')
        price = driver.find_elements_by_xpath('//span[@class="price-big"]')
        description = driver.find_elements_by_xpath('//div[@itemprop="description"]') 

        print model[0].get_attribute('text')

        results = driver.find_elements_by_xpath('//img[starts-with(@id, "view_")]')
        for result in results:
            image = result.get_attribute('src')
            driver.get(image)
            driver.sendKeys(Keys.Control + "s")
            driver.send_keys(Keys.Enter)
            #downloadImage(image, "")
        driver.implicitly_wait(2)

def downloadImage(url, name):
    request = urllib2.Request(url, headers=hdr)
    img = urllib2.urlopen(request).read()
    with open ('test.jpg', 'w') as f: f.write(img)

if __name__ == "__main__":
    driver = webdriver.Firefox()
    scraper(link, 0)
    print "scrap Pr"
    scrapProducts()
    driver.quit()