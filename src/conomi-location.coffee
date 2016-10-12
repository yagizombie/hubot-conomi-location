# Description
#   お店の情報を取得する
#   http://developer.yahoo.co.jp/webapi/map/openlocalplatform/v1/localsearch.html
#
# Configuration:
#   CONOMI_YD_APP_ID Yahoo! JAPANのWebサービスを利用するためのアプリケーションID
#
# Commands:
#   hubot お薦め - (白金台の)お薦めを表示する
#   hubot <text>のお薦め - <text>のお薦めを表示する
#   hubot <text>のお薦めの<genre> - <genre>しばりで<text>のお薦めを表示する
#
# Author:
#   yagizombie <yanagihara+zombie@brainpad.co.jp>

http = require 'http'

APP_ID = process.env.CONOMI_YD_APP_ID
DEFAULT_KEYWORD = '白金台'

table = {
    "和食":"0101",
    "洋食":"0102",
    "バイキング":"0103",
    "中華":"0104",
    "アジア料理":"0105",
    "エスニック":"0105",
    "ラーメン":"0106",
    "カレー":"0107",
    "焼肉":"0108",
    "ホルモン":"0108",
    "ジンギスカン":"0108",
    "鍋":"0109",
    "居酒屋":"0110",
    "ビアホール":"0110",
    "定食":"0111",
    "食堂":"0111",
    "創作料理":"0112",
    "無国籍料理":"0112",
    "無国籍料理":"0113",
    "薬膳":"0113",
    "オーガニック":"0113",
    "持ち帰り":"0114",
    "宅配":"0114",
    "カフェ":"0115",
    "喫茶店":"0115",
    "コーヒー":"0116",
    "茶葉専門店":"0116",
    "パン":"0117",
    "サンドイッチ":"0117",
    "スイーツ":"0118",
    "バー":"0119",
    "パブ":"0120",
    "スナック":"0120",
    "ディスコ":"0121",
    "クラブハウス":"0121",
    "ビアガーデン":"0122",
    "ファミレス":"0123",
    "ファストフード":"0123",
    "パーティー":"0124",
    "カラオケ":"0124",
    "屋形船":"0125",
    "クルージング":"0125",
    "テーマパークレストラン":"0126",
    "オーベルジュ":"0127",
    "その他":"0128"
}

module.exports = (robot) ->
    get_random_value = (arr) ->
        seed = Math.floor(Math.random() * arr.length)
        return arr[seed]

    robot.hear /.*(ぐっとらんち).*$/i, (msg) ->
        msg.send "ぬぬ、ぐっとらんち。献立なんだっけ? http://www.goodlunch.jp/lunch/todays_lunch/index.html"

    robot.hear /.*(玉子屋|たまごや).*$/i, (msg) ->
        msg.send "玉子屋のメニューは...っと http://www.tamagoya.co.jp/menu_list.html"

    robot.hear /.*(おなかすい|お腹すい|腹減っ).*$/i, (msg) ->
        kw = get_random_value ["目黒","白金高輪","麻布十番",DEFAULT_KEYWORD]
        gc = get_random_value ["和食","中華","定食","洋食"]
        get_restaurant_info msg, kw, get_gc msg, gc

    robot.respond /(お薦め|おすすめ|オススメ)$/i, (msg) ->
        get_restaurant_info msg

    robot.respond /(.+)の(お薦め|おすすめ|オススメ)$/i, (msg) ->
        get_restaurant_info msg, msg.match[1]

    robot.respond /(お薦め|おすすめ|オススメ)の(.+)$/i, (msg) ->
        get_restaurant_info msg, DEFAULT_KEYWORD, get_gc msg, msg.match[2]

    robot.respond /(.+)の(お薦め|おすすめ|オススメ)の(.+)$/i, (msg) ->
        get_restaurant_info msg, msg.match[1], get_gc msg, msg.match[3]

    get_gc = (msg, key) ->
        if key of table == true
            return table[key]
        else
            msg.send key + "?? (...ちょっと、分からないなぁ。適当に答えとこう) "
            return "01"

    get_restaurant_info = (msg, keyword=DEFAULT_KEYWORD, gc="01") ->
        p = "/OpenLocalPlatform/V1/localSearch"
        p = p + '?appid=' + encodeURIComponent(APP_ID)
        p = p + '&query=' + encodeURIComponent(keyword)
        p = p + '&sort=rating'
        p = p + '&start=1&results=5&output=json&gc=' + gc
        console.log "http://search.olp.yahooapis.jp" + p
        req = http.get { host:'search.olp.yahooapis.jp', path:p }, (res) ->
            contents = ""
            res.on 'data', (chunk) ->
                contents += "#{chunk}"
            res.on 'end', () ->
                j = JSON.parse contents

                msg.send  keyword + "といえば、、、 (awwyiss)"

                rep = "/quote ∴‥∵‥∴‥∵‥∴‥∴‥∵‥∴‥∵‥∴‥∴‥∵‥∴‥∵‥∴‥∴‥∵‥∴\n"
                # console.log j
                for i, value of j['Feature']
                    rep += "『" + value['Name'] + "』"
                    if "Tel1" of value['Property'] == true
                        rep += "(" + value['Property']['Tel1'] + ")"
                    if "Address" of value['Property'] == true
                        rep += " " + value['Property']['Address'] + " "
                    rep += "\n"
                msg.send rep
                msg.send "とか、どう？ @#{msg.message.user.mention_name}"

        req.on "error", (e) ->
            msg.send "(fu) ひでぶっ!!  ... {e.message}"
