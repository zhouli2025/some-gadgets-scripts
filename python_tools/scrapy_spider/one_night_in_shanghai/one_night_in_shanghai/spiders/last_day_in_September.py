#-*- coding: utf-8 -*-
import scrapy

from one_night_in_shanghai.items import OneNightInShanghaiItem

class last_day_in_September_spider(scrapy.Spider):

    #爬虫名字，唯一，用于区分以后新建的爬虫
    name = "img"

    #可选，定义爬取区域，超出区域的链接不爬取
    allowed_domains = ["so.redocn.com"]  #如果对于页面没有特殊要求，也可以不写

    #定义开始爬取的页面
    start_urls=["http://so.redocn.com/shuiguo/cbaeb9fb.htm"]

    def parse(self, response):  # 友情提示：这个函数名 不能更改，否则后果自负 )= =(
	# 用xpath的方式获取图片的src，具体语法移步[scrapy教程][http://scrapy-chs.readthedocs.io/zh_CN/0.24/topics/selectors.html]
	urls = response.xpath('//div[@class="wrap g-bd"]/div/dl/dd/a/img[not(contains(@class, "lazy"))]/@src').extract()

	for url in urls:

		# 前面我们定义过item，此处将其实例化
		imgItem = OneNightInShanghaiItem()

	        #将获得url赋值给定义好的item
		imgItem['img'] = [url]
		imgItem['gif'] = [] #上面如果定义了gif关键字，就得给初始化

		#将结果交给Pipeline处理
		yield imgItem

	#翻页
	##response.xpath('//a[@class="next"]//@href').extract() #也可以这样
	nexturl=response.xpath(u'//a[contains(text(),"下一页")]/@href').extract()


	domains = ['http://so.redocn.com']
	nexturl_all = domains[0] + nexturl[0]

	if nexturl_all:
		yield scrapy.Request(nexturl_all.encode("utf-8"), callback=self.parse)
