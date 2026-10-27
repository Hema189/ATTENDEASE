class Student {
  final String studentId;
  final int serialNo;
  final String registrationNumber;
  final String name;
  final String academicYear;
  final String branch;
  final String section;
  final bool active;

  Student({
    required this.studentId,
    required this.serialNo,
    required this.registrationNumber,
    required this.name,
    required this.academicYear,
    required this.branch,
    required this.section,
    this.active = true,
  });

  Student copyWith({
    String? name,
    bool? active,
  }) {
    return Student(
      studentId: studentId,
      serialNo: serialNo,
      registrationNumber: registrationNumber,
      name: name ?? this.name,
      academicYear: academicYear,
      branch: branch,
      section: section,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'serialNo': serialNo,
      'registrationNumber': registrationNumber,
      'name': name,
      'academicYear': academicYear,
      'branch': branch,
      'section': section,
      'active': active,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      studentId: map['studentId'] ?? '',
      serialNo: map['serialNo'] ?? 0,
      registrationNumber: map['registrationNumber'] ?? '',
      name: map['name'] ?? '',
      academicYear: map['academicYear'] ?? '',
      branch: map['branch'] ?? '',
      section: map['section'] ?? '',
      active: map['active'] ?? true,
    );
  }

  // Exact 64 initial students for 3rd Year -> IT -> Section C only
  static final List<Student> initial3rdYearITC = [
    Student(studentId: "3Y_IT_C_24B01A12D2", serialNo: 1, registrationNumber: "24B01A12D2", name: "PERURU KOUSALYA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12D3", serialNo: 2, registrationNumber: "24B01A12D3", name: "PIPPARAPALLI NIRMALA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12D4", serialNo: 3, registrationNumber: "24B01A12D4", name: "POLISETI SRAVYA NAGA LAKSHMI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12D5", serialNo: 4, registrationNumber: "24B01A12D5", name: "POTNURU SUSHMA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12D6", serialNo: 5, registrationNumber: "24B01A12D6", name: "PUDI ANUSHKA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12D7", serialNo: 6, registrationNumber: "24B01A12D7", name: "PULAVARTHI BHANU PRANATHI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12D8", serialNo: 7, registrationNumber: "24B01A12D8", name: "PULLEPU TAPASWI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12D9", serialNo: 8, registrationNumber: "24B01A12D9", name: "PUSHYATHA SRI VAISHNAVI KORLA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12E0", serialNo: 9, registrationNumber: "24B01A12E0", name: "PYDIMARRI SRIVALLI NAGA VAISHNAVI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12E1", serialNo: 10, registrationNumber: "24B01A12E1", name: "RACHAMADUGU HASINI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12E2", serialNo: 11, registrationNumber: "24B01A12E2", name: "RACHAMADUGU LIKITHA HASINI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12E3", serialNo: 12, registrationNumber: "24B01A12E3", name: "RATNALA RENUKA DEVI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12E4", serialNo: 13, registrationNumber: "24B01A12E4", name: "RAVIKRINDI RAAGA VARSHINI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12E5", serialNo: 14, registrationNumber: "24B01A12E5", name: "REGANTI GAYATHRI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12E6", serialNo: 15, registrationNumber: "24B01A12E6", name: "REKKALA SIREESHA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12E7", serialNo: 16, registrationNumber: "24B01A12E7", name: "RUDRARAJU JYOTSNA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12E8", serialNo: 17, registrationNumber: "24B01A12E8", name: "SAHITHI ACHYUTHA ISHWARYA KALLA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12E9", serialNo: 18, registrationNumber: "24B01A12E9", name: "SAI NAGA SUJITHA NAKKA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12F0", serialNo: 19, registrationNumber: "24B01A12F0", name: "SAKALA SPURTHI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12F1", serialNo: 20, registrationNumber: "24B01A12F1", name: "SALA UDAYA VENKATESWARI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12F2", serialNo: 21, registrationNumber: "24B01A12F2", name: "SAMATHAM KAVYA JYOTSHNA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12F3", serialNo: 22, registrationNumber: "24B01A12F3", name: "SAMIREDDI VARSHINI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12F4", serialNo: 23, registrationNumber: "24B01A12F4", name: "SAMUDALAPALEM APURVA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12F5", serialNo: 24, registrationNumber: "24B01A12F5", name: "SANTOSHI INDUGULA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12F6", serialNo: 25, registrationNumber: "24B01A12F6", name: "SATTI TARUNIKA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12F7", serialNo: 26, registrationNumber: "24B01A12F7", name: "SEELAM LOHITHA RANI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12F8", serialNo: 27, registrationNumber: "24B01A12F8", name: "SHAIK AFRIN", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12F9", serialNo: 28, registrationNumber: "24B01A12F9", name: "SHAIK AISHA THASIM", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12G0", serialNo: 29, registrationNumber: "24B01A12G0", name: "SHAIK CHINNA FAREEDAGARI SANA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12G1", serialNo: 30, registrationNumber: "24B01A12G1", name: "SHAIK KOWSAR", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12G2", serialNo: 31, registrationNumber: "24B01A12G2", name: "SHAIK MEHARUNNISA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12G3", serialNo: 32, registrationNumber: "24B01A12G3", name: "SHAIK NAZMA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12G4", serialNo: 33, registrationNumber: "24B01A12G4", name: "SHAIK SONA KOUSAR", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12G5", serialNo: 34, registrationNumber: "24B01A12G5", name: "SHAIK VENENSHA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12G6", serialNo: 35, registrationNumber: "24B01A12G6", name: "SOMU SRAVYA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12G7", serialNo: 36, registrationNumber: "24B01A12G7", name: "SRIKHAKOLLU NAVYA SRI LAKSHMI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12G8", serialNo: 37, registrationNumber: "24B01A12G8", name: "SRIREDDY HEMASRI MADHURI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12G9", serialNo: 38, registrationNumber: "24B01A12G9", name: "SWETHA NANDHINI LAKKIMSETTY", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12H0", serialNo: 39, registrationNumber: "24B01A12H0", name: "TANETI PRANITHA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12H1", serialNo: 40, registrationNumber: "24B01A12H1", name: "TANGUDU SHIVANI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12H2", serialNo: 41, registrationNumber: "24B01A12H2", name: "TEJASWI KUKUNURI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12H3", serialNo: 42, registrationNumber: "24B01A12H3", name: "TELAGAMSETTI GNANA SAMHITHA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12H4", serialNo: 43, registrationNumber: "24B01A12H4", name: "TERLU GEETA MADHURI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12H5", serialNo: 44, registrationNumber: "24B01A12H5", name: "THOKALA PAVANI VIJAYA SYAMALA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12H6", serialNo: 45, registrationNumber: "24B01A12H6", name: "THOTA HARSHITHA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12H7", serialNo: 46, registrationNumber: "24B01A12H7", name: "THOTAKURA RUPA SAI LAKSHMI RISHITHA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12H8", serialNo: 47, registrationNumber: "24B01A12H8", name: "TOTA BHUVANASRI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12H9", serialNo: 48, registrationNumber: "24B01A12H9", name: "TUMMALA PENTA MAHESWARI SRAVYA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12I0", serialNo: 49, registrationNumber: "24B01A12I0", name: "UNDAVILLI AMRUTA SAI SURYA GEETIKA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12I1", serialNo: 50, registrationNumber: "24B01A12I1", name: "VADAPARTHI HEMA LATHA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12I2", serialNo: 51, registrationNumber: "24B01A12I2", name: "VALLABHANI KRISHMA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12I3", serialNo: 52, registrationNumber: "24B01A12I3", name: "VALLURI DEVI DEEPIKA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12I4", serialNo: 53, registrationNumber: "24B01A12I4", name: "VARADA HARITHA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12I5", serialNo: 54, registrationNumber: "24B01A12I5", name: "VASKURI RADHI SRUJANA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12I6", serialNo: 55, registrationNumber: "24B01A12I6", name: "VASKURI SANDHYA KRISHNA SRI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12I7", serialNo: 56, registrationNumber: "24B01A12I7", name: "VEMA TEJASAI VYSHNAVI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12I8", serialNo: 57, registrationNumber: "24B01A12I8", name: "VINDULA SRUTHI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12I9", serialNo: 58, registrationNumber: "24B01A12I9", name: "VUTA GEETHA SRIVANI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12J0", serialNo: 59, registrationNumber: "24B01A12J0", name: "YADALA YASO SREENIDHI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12J1", serialNo: 60, registrationNumber: "24B01A12J1", name: "YALLA SINDHU SRI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12J2", serialNo: 61, registrationNumber: "24B01A12J2", name: "YANNAMSETTI SIRISHA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12J3", serialNo: 62, registrationNumber: "24B01A12J3", name: "YEDIDA TEJASWINI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12J4", serialNo: 63, registrationNumber: "24B01A12J4", name: "YENUMULA MOUNIKA", academicYear: "3rd Year", branch: "IT", section: "Section C"),
    Student(studentId: "3Y_IT_C_24B01A12J5", serialNo: 64, registrationNumber: "24B01A12J5", name: "YERUVA PRANATHI", academicYear: "3rd Year", branch: "IT", section: "Section C"),
  ];
}
