import Foundation

@testable import n_Weather

extension WeatherModel {
    static func mock(
        cod: String = "200",
        list: [Forecast] = [.mock()],
        city: City = .mock(),
    ) -> WeatherModel {
        return WeatherModel(
            cod: cod,
            list: list,
            city: city
        )
    }
}

extension Forecast {
    static func mock(
        datetime: Int = 1764759478,
        date: String = "2025-12-03 10:57:49",
        main: Main = .mock(),
        weather: [Weather] = [.mock()],
        wind: Wind = .mock(),
        visibility: Int = 10000
    ) -> Forecast {
        let jsonString = """
                    {
                    "dt" : \(datetime),
                    "dt_txt": "\(date)",
                    "main": {
                        "temp": \(main.temp),
                        "tempMin": \(main.tempMin),
                        "tempMax": \(main.tempMax),
                        "humidity": \(main.humidity),
                        "feelsLike": \(main.feelsLike)
                    },
                    "weather": [
                        {
                        "main": "\(weather[0].main)",
                        "description": "\(weather[0].description)",
                        "id": \(weather[0].id)
                        }
                    ]
                    }
                """

        _ = Data(jsonString.utf8)

        return Forecast(datetime: datetime, date: date, main: main, weather: weather, wind: wind, visibility: visibility)
    }
}

extension Coordinates {
    static func mock(
        lon: Double = 37.61,
        lat: Double = 55.75
    ) -> Coordinates {
        return Coordinates(lon: lon, lat: lat)
    }
}

extension City {
    static func mock(
        name: String = "Moscow",
        coord: Coordinates = .mock(),
        sunrise: Int = 1704081600,
        sunset: Int = 1704117600
    ) -> City {
        return City(
            name: name,
            coord: coord,
            sunrise: sunrise,
            sunset: sunset
        )
    }
}

extension Main {
    static func mock(
        temp: Double = 29.15,
        tempMin: Double = 28.15,
        tempMax: Double = 30.15,
        humidity: Int = 60,
        feelsLike: Double = 28.2,
        pressure: Int = 1013
    ) -> Main {
        return Main(
            temp: temp,
            tempMin: tempMin,
            tempMax: tempMax,
            humidity: humidity,
            pressure: pressure,
            feelsLike: feelsLike
        )
    }
}

extension Weather {
    static func mock(
        main: String = "clearsky",
        description: String = "clear sky",
        id: Int = 800
    ) -> Weather {
        return Weather(
            main: main,
            description: description,
            id: id
        )
    }
}
extension Wind {
    static func mock(
        speed: Double = 5.0,
        deg: Int = 180,
        gust: Double = 0.0
    ) -> Wind {
        return Wind(
            speed: speed,
            deg: deg,
            gust: gust
        )
    }
}

