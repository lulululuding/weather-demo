class HourlyForecast {
  String time; //	预报时间，格式yyyy-MM-dd hh:mm	2013-12-30 13:00
  int tmp; //	温度	2
  String cond_code; //	天气状况代码	101
  String cond_txt; //天气状况代码	多云
  String wind_deg; //风向360角度	290
  String wind_dir; //风向	西北
  String wind_sc; //风力	3-4
  String wind_spd; //风速，公里/小时	15
  String hum; //	相对湿度	30
  String pres; //大气压强	1030
  String dew; //露点温度	12
  String cloud; //云量	23
  bool isDay;

  HourlyForecast({
    this.tmp,
    this.isDay,
    this.time
  });

  HourlyForecast.formJson(Map<String, dynamic> json)
      : time = json['time'],
        tmp = json['tmp'],
        cond_code = json['cond_code'],
        cond_txt = json['cond_txt'],
        wind_deg = json['wind_deg'],
        wind_dir = json['wind_dir'],
        wind_sc = json['wind_sc'],
        wind_spd = json['wind_spd'],
        hum = json['hum'],
        pres = json['pres'],
        dew = json['dew'],
        cloud = json['cloud'] {
    isDay = DateTime.parse(time).hour > 6 && DateTime.parse(time).hour < 18;
  }

  String getHourTime() {
    return time.split(' ')[1];
  }
}