class Utils{
  // 月份天数
  final List days = [31,28,31,30,31,30,31,31,30,31,30,31];

  ///
  /// 获取学生生日与当天差值
  ///
  int getDayDifference(Map student){
    if(student["release"] != 0) return -1;
    DateTime now = DateTime.now();
    int nowMonth = now.month;
    int nowDay = now.day;
    int month = int.parse(student["birthday"]["month"].toString());
    int day = int.parse(student["birthday"]["day"].toString());
    //如果月份相差大于1，或者当前月份大于生日月份，说明生日已过
    if((nowMonth-month).abs() > 1 || nowMonth > month) return -1;
    if(nowMonth == month) return day - nowDay;
    if(month == 2){
      if( (now.year % 4 == 0 && now.year % 100 != 0) ||
          (now.year% 100 == 0 && now.year% 400 == 0)){
        days[1] = 29;
      }else{
        days[1] = 28;
      }
    }
    return days[nowMonth-1] - nowDay + day;
  }

}
