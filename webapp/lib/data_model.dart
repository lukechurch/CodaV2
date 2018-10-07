/**
 * Represents the main data types used in Coda.
 */
library coda.model;

/// A collection of messages and code schemes.
class Dataset {
  String name;
  List<Message> messages;
  List<Scheme> codeSchemes;

  Dataset(this.name) {
    messages = [];
    codeSchemes = [];
  }
  Dataset.fromJson(Map jsonDataset) {
    name = jsonDataset['Name'];
    messages = (jsonDataset['Documents'] as List).map<Message>((jsonDocument) => new Message.fromJson(jsonDocument)).toList();
    codeSchemes = (jsonDataset['CodeSchemes'] as List).map<Scheme>((jsonScheme) => new Scheme.fromJson(jsonScheme)).toList();
  }
}

/// A textual message being coded.
class Message {
  String messageID;
  String text;
  DateTime creationDateTime;
  List<Label> labels;

  Message(this.messageID, this.text, this.creationDateTime) {
    labels = [];
  }
  Message.fromJson(Map jsonDocument) {
    messageID = jsonDocument['MessageID'];
    text = jsonDocument['Text'];
    creationDateTime = DateTime.parse(jsonDocument['CreationDateTimeUTC']);
    labels = (jsonDocument['Labels'] as List).map<Label>((jsonLabel) => new Label.fromJson(jsonLabel)).toList();
  }

  @override
  String toString() => "$messageID: $text $labels";
}

/// A code/label assigned to a message.
class Label {
  String schemeID;
  DateTime dateTime;
  String valueID;
  String labelOrigin;

  Label(this.schemeID, this.dateTime, this.valueID, this.labelOrigin);
  Label.fromJson(Map jsonLabel) {
    schemeID = jsonLabel['SchemeID'];
    dateTime = DateTime.parse(jsonLabel['DateTimeUTC']);
    valueID = jsonLabel['ValueID'];
    labelOrigin = jsonLabel['LabelOrigin'];
  }
  @override
  String toString() => "$schemeID: $valueID $labelOrigin";
}

/// A code scheme being used for coding/labelling messsages.
class Scheme {
  String schemeID;
  List<Map> codes;

  Scheme(this.schemeID) {
    codes = [];
  }
  Scheme.fromJson(Map jsonScheme) {
    schemeID = jsonScheme['SchemeID'];
    codes = [];
    jsonScheme['Codes'].forEach((jsonCode) {
      var code = {
        'name': jsonCode['FriendlyName'],
        'valueID': jsonCode['ValueID'],
        'shortcut': jsonCode['Shortcut']
      };
      if (jsonCode.containsKey('Colour')) {
        code['colour'] = new Colour.hex(jsonCode['Colour']);
      } else {
        code['colour'] = new Colour();
      }
      codes.add(code);
    });
  }
}

/// A simple colour class for transforming between the data model colours and css colours.
/// Inspired by https://github.com/MichaelFenwick/Color/blob/master/lib/hex_color.dart
class Colour {
  int r = 255;
  int g = 255;
  int b = 255;

  Colour();
  Colour.hex(String hexCode) {
    if (hexCode.startsWith('#')) {
      hexCode = hexCode.substring(1);
    }
    List<String> hexDigits = hexCode.split('');
    r = int.parse(hexDigits.sublist(0, 2).join(), radix: 16);
    g = int.parse(hexDigits.sublist(2, 4).join(), radix: 16);
    b = int.parse(hexDigits.sublist(4).join(), radix: 16);
  }

  String get rHex => r.toInt().toRadixString(16).padLeft(2, '0');
  String get gHex => g.toInt().toRadixString(16).padLeft(2, '0');
  String get bHex => b.toInt().toRadixString(16).padLeft(2, '0');

  String toString() => '$rHex$gHex$bHex';
  String toCssString() => '#$rHex$gHex$bHex';

  get hashCode {
    return 256 * 256 * r + 256 * g + b;
  }

  operator ==(Object other) => other is Colour && this.hashCode == other.hashCode;
}
