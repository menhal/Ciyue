# 示例

[English](./README.md) | 中文

## 使用 `initDict` 初始化

`initDict` 方法可以更精细地控制初始化过程。

```dart
import 'package:dict_reader/dict_reader.dart';

void main() async {
  final dictReader = DictReader("MDX FILE PATH");

  // 仅初始化头部
  await dictReader.initDict(readKeys: false, readRecordBlockInfo: false);

  // ... 执行操作

  // 完全初始化
  await dictReader.initDict();

  // ... 执行其他操作

  await dictReader.close();
}
```

`initDict` 的参数：
- `readKeys`: 是否读取密钥列表。默认为 `true`。
- `readRecordBlockInfo`: 是否读取记录块信息。默认为 `true`。
- `readHeader`: 是否读取词典标题。默认为 `true`。

## 定位

```dart
import 'package:dict_reader/dict_reader.dart';

void main() async {
  final dictReader = DictReader("MDX FILE PATH");
  await dictReader.initDict();

  final offsetInfo = await dictReader.locate("go");
  print(await dictReader.readOneMdx(offsetInfo!));

  await dictReader.close();
}
```

## 搜索

```dart
import 'package:dict_reader/dict_reader.dart';

void main() async {
  final dictReader = DictReader("MDX FILE PATH");
  await dictReader.initDict();

  final keys = dictReader.search("go");
  print(keys);

  final keysWithLimit = dictReader.search("go", limit: 1);
  print(keysWithLimit);

  await dictReader.close();
}
```

## 是否存在

```dart
import 'package:dict_reader/dict_reader.dart';

void main() async {
  final dictReader = DictReader("MDX FILE PATH");
  await dictReader.initDict();

  final keyExists = dictReader.exist("go");
  print(keyExists);

  final keyDoesNotExist = dictReader.exist("non-existent-key");
  print(keyDoesNotExist);

  await dictReader.close();
}
```

## 直接读取数据

```dart
import 'package:dict_reader/dict_reader.dart';

void main() async {
  final dictReader = DictReader("MDX FILE PATH");
  await dictReader.initDict();

  await for (final MdxRecord(:keyText, :data) in dictReader.readWithMdxData()) {
    print("$keyText, $data");
  }

  await dictReader.close();
}
```

## 读取数据 offset，之后读取数据

```dart
import 'package:dict_reader/dict_reader.dart';

void main() async {
  final dictReader = DictReader("MDX FILE PATH");
  await dictReader.initDict();

  final map = <String, RecordOffsetInfo>{};
  await for (final offsetInfo in dictReader.readWithOffset()) {
    map[offsetInfo.keyText] = offsetInfo;
  }

  final offsetInfo = map["go"];
  print(await dictReader.readOneMdx(offsetInfo!));

  await dictReader.close();
}
```

## 当已保存数据 offset，读取数据

```dart
import 'package:dict_reader/dict_reader.dart';

// ...

void main() async {
  // ...

  final dictReader = DictReader("MDX FILE PATH");
  // Pass false to reduce initialization time
  await dictReader.initDict(readKeys: false, readRecordBlockInfo: false);

  final offsetInfo = map["go"];
  print(await dictReader.readOneMdx(offsetInfo!));

  await dictReader.close();
}
```
