import groovy.xml.MarkupBuilder

def body = new File('/Users/hlf/Library/Containers/com.tencent.xinWeChat/Data/Library/Application Support/com.tencent.xinWeChat/2.0b4.0.9/cb1b7825ae13fd36e185aa278214f847/Message/MessageTemp/acb97ccc746cbbc17f8b3ee29a989105/File/H262507_20201217090300.tns')

def arr_lengths = "1 5 7 1 7 2 27 1 5 1 4 1 4 1 4 5 2 4 12 3 20 5 2 1 8 8 1 5 5 1 2 6 4 1 3 3 3 6 8 1 2 2 2 7 7 7 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 17"
def arr_names = "HNS_KBN ATESAKI_CD RECORD_CD_HN DATA_KBN RECORD_CD_OLD RECORD_BK DAMI_HN KBN NW COMPANY_CD DATA_KBN_2 BUNGEN_KBN SYOURYU_SIIRESAKI KYOUJYOU_CD MOTIKOMISAKI TANTOBUSYO_CD TANTOSYA_CD BUTURYU_SIIRESAKI HINBAN HINBAN_YB HINMEI_EN GROUP_NO UKEIRE KNKT_KBN ST_YMD EN_YMD KANBAN_KBN NOUNYUKIGU_CD TANI HOSOUBASYO_KBN SYUBETU_KBN SEBAN CYCLE HATYUKAISU MAX_MAISU MIN_MAISU KABAN_MAISU MANAGEMENT_CD GKKIRIKAE_YMD GK_KBN NAIJI_M NA1_M NA2_M NAIJI_QTY NA1_QTY NA2_QTY NTUKI_1 NTUKI_2 NTUKI_3 NTUKI_4 NTUKI_5 NTUKI_6 NTUKI_7 NTUKI_8 NTUKI_9 NTUKI_10 NTUKI_11 NTUKI_12 NTUKI_13 NTUKI_14 NTUKI_15 NTUKI_16 NTUKI_17 NTUKI_18 NTUKI_19 NTUKI_20 NTUKI_21 NTUKI_22 NTUKI_23 NTUKI_24 NTUKI_25 NTUKI_26 NTUKI_27 NTUKI_28 NTUKI_29 NTUKI_30 NTUKI_31 DAMI"

def content = body.readLines().asList()
def lengthgroup = arr_lengths.split()
def labelgroup = arr_names.split()
def LineNumber = "LINENUMBER"

//   Merge list
def contentlist = []
int t = 1
def str = ''
content.each{ tns->
    if(tns[0] == "D"){
        if(tns[21..22] == '02'){
            tns = tns[50..-1]
        }
        str = str + tns
        if(t % 2 == 0){
            contentlist.add(str)
            str = ''
        }
        t++
    }
}


def writer = new StringWriter()

int index = 1
new MarkupBuilder(writer).Root{
    IT_DATA{
        contentlist.each { tnscontent  ->
            item {
                    "$LineNumber"(index) // 添加 line no
                    int i = 0
                    lengthgroup.each { length ->
                        int k = 0
                        int len = 0
                        int n = length.toInteger()
                        def context = ""
                        int tnslength = tnscontent.length() - 1

                        for (int j = 0; j < n; j++) {
                            if ( k < n  && j < tnslength) {
                                String temp = tnscontent[j]
                                context = context.plus(temp)
                                char[] chars = temp.toCharArray()
                                // 判断是全角字符
                                if(!(('\u0020' <= chars[0])&& (chars[0] <= '\u007E'))
                                        && !(('\uFF61' <=chars[0]) && (chars[0] <= '\uFF9F'))){
                                    k = k + 2
                                } else {
                                    k = k + 1
                                }
                            }
                            if( k == n ){
                                j = n
                            }
                        }
                        len = context.length()
                        tnscontent = tnscontent.substring(len)
                        context = context.replaceAll("\\s*", "")  //去掉字符串中所有空格，包括首尾
                        context = context.replaceAll('　', '')  //去掉字符串中所有空格，包括首尾
                        def label = labelgroup[i] //Define the variable of label name
                        //
                        "$label"(context) //"$[labelname here]"(List[i]) could give you a dynamically label XML
                        i++
                    }
                }
            index++
        }
    }
}

println(writer)
def xmlFile = "/Users/hlf/Desktop/pp01_027_output.xml"
PrintWriter pw = new PrintWriter(xmlFile)
pw.write(writer.toString())
pw.close()



