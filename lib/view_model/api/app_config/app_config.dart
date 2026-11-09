import 'package:flutter/foundation.dart';

enum BuildMode { debug, release }

final BuildMode buldMode = kReleaseMode ? BuildMode.release : BuildMode.debug;
