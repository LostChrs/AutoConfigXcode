import configparser
import os
import shutil
import sys

from pbxproj import *
from pbxproj.pbxextensions import *

reload(sys)
sys.setdefaultencoding("utf-8")

#Public Var

def printPlist(plist):
    os.system('/usr/libexec/PlistBuddy -c "print" %s' % (plist))

def setToPlist(key,value,plist):
    os.system('/usr/libexec/PlistBuddy -c "Set %s %s" %s' % (key,value,plist))

def addToPlist(key,value,plist):
    os.system('/usr/libexec/PlistBuddy -c "Add :%s string %s" %s' % (key,value,plist))

def readConfig():
    curPath = sys.path[0]
    resPath = curPath + "/Res/"
    cf = configparser.ConfigParser()
    cf.read(curPath + "/Config.conf")

    UM_APPID = cf.get("SDK", "UM_APPID")
    UNITY_APPID = cf.get("SDK", "UNITY_APPID")
    UNITY_ADSID = cf.get("SDK", "UNITY_ADSID")
    VUNGLE_APPID = cf.get("SDK", "VUNGLE_APPID")
    VUNGLE_ADSID = cf.get("SDK", "VUNGLE_ADSID")
    WX_APPID = cf.get("SDK", "WX_APPID")
    BUNDLEID = cf.get("XCODE", "BUNDLEID")
    PROJECT_PATH = cf.get("XCODE", "PROJECT_PATH")

    XCODE_PATH = os.path.dirname(PROJECT_PATH)
    PRODUCT_NAME = os.path.splitext(os.path.basename(PROJECT_PATH))[0]
    IOS_PATH = XCODE_PATH + "/ios/"

    PLIST_PATH = IOS_PATH + "info.plist"
    #os.system('/usr/libexec/PlistBuddy -c "print" %s' % (PLIST_PATH))
    printPlist(PLIST_PATH)
    setToPlist("CFBundleIdentifier",BUNDLEID,PLIST_PATH)
    addToPlist("AppLovinSdkKey","sfsdfsd",PLIST_PATH)
    printPlist(PLIST_PATH)

    with open(resPath + "PfuAdsManager.h", "r") as file1:
        allcode = file1.read()
        #print allcode
        outfile = open(XCODE_PATH + "/PfuAdsManager.h", "w")
        outfile.write('#define UMID @"' + UM_APPID + '"\n')
        outfile.write('#define UNITYID @"' + UNITY_APPID + '"\n')
        outfile.write('#define AdsIdUnity @"' + UNITY_ADSID + '"\n')
        outfile.write('#define VUNGLEID @"' + VUNGLE_APPID + '"\n')
        outfile.write('#define AdsIdVungle @"' + VUNGLE_ADSID + '"\n')
        outfile.write('#define WXAppId @"' + WX_APPID + '"\n')
        outfile.write(allcode)

        outfile.flush()
        outfile.close()

        #copyfile
        # print("Copy Files...")
        # shutil.copytree(resPath + "Ads", XCODE_PATH + "/Ads")
        # shutil.copy(resPath + "PfuAdsManager.mm",
        #             XCODE_PATH + "/PfuAdsManager.mm")
        # shutil.copy(resPath + "PfuNative.h", XCODE_PATH + "/PfuNative.h")
        # shutil.copy(resPath + "PfuNative.m", XCODE_PATH + "/PfuNative.m")
        # print("Copy Success")
        print("Config Xcode...")
        project = XcodeProject.load(u'' + PROJECT_PATH + '/project.pbxproj')
        pbxprojects = project.objects.get_objects_in_section(u'PBXProject')
        # target = project.get_target_by_name(u'hello_world-mobile')
        # for pbxproject in pbxprojects:
        #         pbxproject.set_

        project.save()


if __name__ == "__main__":
    readConfig()
