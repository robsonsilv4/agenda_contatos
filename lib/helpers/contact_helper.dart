import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imageColumn = "imageColumn";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _database;

  Future<Database> get database async {
    if (database != null) {
      return _database;
    } else {
      _database = await initDb();
      return _database;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contacts.db");

    return await openDatabase(path, version: 1, onCreate: (
      Database database,
      int newerVersion,
    ) async {
      await database.execute(
        "CREATE TABLE $contactTable($idColumn INTERGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imageColumn TEXT)",
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await database;
    contact.id = await dbContact.insert(
      contactTable,
      contact.toMap(),
    );
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await database;
    List<Map> maps = await dbContact.query(
      contactTable,
      columns: [
        idColumn,
        nameColumn,
        emailColumn,
        phoneColumn,
        imageColumn,
      ],
      where: "$idColumn = ?",
      whereArgs: [id],
    );

    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List> getAllContacts() async {
    Database dbContact = await database;

    List listMap = await dbContact.rawQuery(
      "SELECT * FROM $contactTable",
    );
    List<Contact> listContact = List();

    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }

    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await database;
    return Sqflite.firstIntValue(
      await dbContact.rawQuery(
        "SELECT COUNT(*) FROM $contactTable",
      ),
    );
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await database;
    return await dbContact.delete(
      contactTable,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await database;
    return await dbContact.update(
      contactTable,
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id],
    );
  }

  Future close() async {
    Database dbContact = await database;
    dbContact.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String image;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    image = map[imageColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imageColumn: image
    };

    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, image: $image)";
  }
}
