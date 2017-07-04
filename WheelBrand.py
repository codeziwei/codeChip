#python
#找到主屏幕Screen 默认参数是0 即主屏幕 
scr=Screen()
scr.highlight(1)
#wait(10)
#找到应用Vysor
vysor=find("vysor.png")
myx=vysor.getX()-73
myy=vysor.getY()+70
myr=Region(myx,myy-40,530,880)
myr.highlight(1)

#注册事件，关闭每30分钟出现的广告

def myHandler(event):
    print("exec myHandler")
    if exists("adClose.png"):
        click("adClose.png")
        print("exists ad Close")
    #TODO: 广告的 x 有不同图片
onAppear("adClose.png",myHandler)
# observe(True) 是python 向后兼容临时方案  http://sikulix-2014.readthedocs.io/en/latest/region.html#Region.observeInBackground 
observe(True)

   
#鼠标焦点移动到应用
#hover("miaocheku2.png")

#dragDrop("aerflumiou-1.png","miaocheku2-1.png")

#循环滚动点击，直到不可滚动
while True:
    #点击
    bx=myx+40
    by=myy+180
    sfilename=""
    while True:
        brandRegion=Region(bx,by,150,30)
        brandRegion.highlight(1)
        click(brandRegion)
        wait(1.5)
        if exists("sbadktobrand-1.png"):
            if sfilename!="":
                if exists(sfilename):
                    click("fanhui.png")
                    by=by+30
                    wait(2)
                    continue
            sfilename=scr.capture(myx,myy,530,880).filename

            #品牌下的车系
            while True:
                wheel(WHEEL_DOWN,6) 
                wait(1.5)
                #
                icons =findAll("xiangqing.png")
                icons=sorted(icons,key=lambda icon:icon.getY())                                                          
                for s in icons :
                    click(s)
                    wait(1.5)
                    hover("yellowwan-1.png")
                    #车辆信息
                    while True:
                        if exists("meiyougengduole.png") or  exists("fabuxunche.png"):
                            click("fanhui.png")
                            wait(1.5)
                            break
                        wheel(WHEEL_DOWN, 40)
                        wait(1.5)
                    #
                #车系滚动 退出
                capiconsfile=scr.capture(myx,myy,530,880)
                print("Saved capicons as "+capiconsfile.filename)
                hover(find("xiangqing.png"))
                wheel(WHEEL_DOWN,6) 
                wait(1.5)
                if exists(capiconsfile.filename):
                    click("sbacktobrand2.png")
                    wait(2)
                    break
        wait(1.5)
        #点击退出
        
        if by>880:
            #确认滚动在当前页
            hover(brandRegion)
            print("880")
            break
        by=by+30
        
    
    #brandRegion=Region(bx,myy+by,150,30) 
    #brandRegion.highlight(3)
    
    #click(brandRegion)
    

    #滚动
    capfile=scr.capture(myx,myy,530,880)
    print("Saved screen as "+capfile.filename)
    wheel(WHEEL_DOWN,6) 
    wait(1.5)
    if exists(capfile.filename):
       break
popup("OVER") 
 
