import QtQuick 2.3
import visual.shapes 1.0

SvgView{
    property color color: 'white'
    content:
        '<svg class="svg-icon" fill="currentColor" overflow="hidden" style="height:1em;vertical-align:middle;width:1em" version="1.1" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">' +
          '<path d="m512 324.27v-187.73c0-6.8267-3.4133-13.653-10.24-13.653-6.8267-3.4133-13.653-3.4133-17.067 0l-477.87 307.2c-3.4133 3.4133-6.8267 6.8267-6.8267 13.653s3.4133 10.24 6.8267 13.653l477.87 341.33c6.8267 3.4133 13.653 3.4133 17.067 0 6.8267-3.4133 10.24-10.24 10.24-13.653v-187.73c249.17 10.24 474.45 235.52 477.87 290.13 0 10.24 6.8267 17.067 17.067 17.067s17.067-6.8267 17.067-17.067c-3.4133-225.28-170.67-552.96-512-563.2z" fill=""/>' +
          '<path d="m997.87 901.18c-4.9324-3.0075-6.3834-5.8409-7.6519-14.942-3.5657-25.583-44.834-76.65-100.44-124.28-92.227-79.01-200.73-134.8-303.1-155.84-17.57-3.6113-49.728-7.9713-65.958-8.9425l-8.7341-0.52265-7e-3 92.903c-5e-3 59.894-0.44664 94.487-1.2449 97.361-1.3459 4.8461-8.9763 12.292-13.85 13.515-1.5798 0.3965-4.9271 4e-3 -7.4385-0.87201-6.3698-2.2222-482.15-342.19-485.54-346.94-3.9892-5.5902-3.7292-13.626 0.60235-18.618 3.1344-3.6127 480.6-311.28 485.47-312.83 3.8368-1.2178 16.235 3.3868 18.966 7.0438 2.3972 3.2101 2.4469 4.9995 2.7763 99.981l0.33534 96.713 15.788 0.83349c116.51 6.1507 224.71 54.046 310.34 137.37 31.128 30.289 52.691 56.203 76.766 92.255 32.642 48.881 56.751 97.683 75.284 152.4 19.2 56.681 30.526 114.04 32.205 163.1 0.6288 18.378 0.4634 21.412-1.3511 24.781-4.1488 7.704-15.311 10.365-23.228 5.5371z" fill="' + color + '" stroke-width="0"/>' +
        '</svg>'
}
