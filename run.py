import configparser
import os
import shutil
import sys

from pbxproj import *
from pbxproj.pbxextensions import *

reload(sys)
sys.setdefaultencoding("utf-8")


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
        print "Copy Files..."
        shutil.copytree(resPath + "Ads", XCODE_PATH + "/Ads")
        shutil.copy(resPath + "PfuAdsManager.mm", XCODE_PATH + "/PfuAdsManager.mm")
        shutil.copy(resPath + "PfuNative.h", XCODE_PATH + "/PfuNative.h")
        shutil.copy(resPath + "PfuNative.m", XCODE_PATH + "/PfuNative.m")
        print "Copy Success"
        print "Config Xcode..."


if __name__ == "__main__":
    readConfig()
