var SNAP_KEY = 'alt+c';
var SNAP_LEFT_KEY = 'alt+LEFT';
var SNAP_RIGHT_KEY = 'alt+RIGHT';

function showMessage(message, persist) {
  var ass_start = mp.get_property_osd('osd-ass-cc/0');
  var ass_stop = mp.get_property_osd('osd-ass-cc/1');

  mp.osd_message(ass_start + '{\\fs16}' + message + ass_stop, persist ? 999 : 2);
}

function snapSubToSecondarySub() {
  var subStart = mp.get_property('sub-start/full');
  var secondarySubStart = mp.get_property('secondary-sub-start/full');
  if (subStart && secondarySubStart) {
    var diff = Math.round((secondarySubStart - subStart) * 100) / 100;
    mp.set_property('sub-delay', diff);
    // var message = 'Sub-start: ' + subStart + '\nSecondary-sub: ' + secondarySubStart + '\nDelay:' + diff;
    var message = 'Sub delay: ' + diff * 100 + ' ms';
    showMessage(message);
  } else {
    var sub_delay = Math.round(mp.get_property('sub-delay') * 100);
    showMessage('Sub delay: ' + sub_delay + 'ms\\NSub or secondary sub not present');
  }
}

function snapLeftSubToSecondarySub() {
  mp.command('no-osd sub-step -1');
  snapSubToSecondarySub();
}

function snapRightSubToSecondarySub() {
  mp.command('no-osd sub-step 1');
  snapSubToSecondarySub();
}

mp.add_key_binding(SNAP_KEY, 'sub-to-sec-sub', snapSubToSecondarySub);
mp.add_key_binding(SNAP_LEFT_KEY, 'left-sub-to-sec-sub', snapLeftSubToSecondarySub);
mp.add_key_binding(SNAP_RIGHT_KEY, 'right-sub-to-sec-sub', snapRightSubToSecondarySub);
