package com.example.data.repository

import com.example.data.model.Branch
import com.example.data.model.Student
import com.example.data.model.User
import com.example.data.model.UserRole
import java.security.MessageDigest

object InitialData {

    fun hashPassword(password: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val hash = digest.digest(password.toByteArray(Charsets.UTF_8))
        return hash.joinToString("") { "%02x".format(it) }
    }

    val INITIAL_BRANCHES = listOf(
        Branch(code = "IT", name = "Information Technology", displayOrder = 1),
        Branch(code = "CSE", name = "Computer Science & Engineering", displayOrder = 2),
        Branch(code = "ECE", name = "Electronics & Communication Engineering", displayOrder = 3),
        Branch(code = "EEE", name = "Electrical & Electronics Engineering", displayOrder = 4),
        Branch(code = "ME", name = "Mechanical Engineering", displayOrder = 5),
        Branch(code = "CIVIL", name = "Civil Engineering", displayOrder = 6)
    )

    val INITIAL_USERS = listOf(
        User(
            userId = "admin_01",
            registrationNumber = "ADMIN",
            name = "Campus Administrator",
            passwordHash = hashPassword("Admin@123"),
            role = UserRole.ADMIN
        ),
        User(
            userId = "faculty_01",
            registrationNumber = "FAC001",
            name = "Dr. K. Ramesh (IT Dept)",
            passwordHash = hashPassword("Faculty@123"),
            role = UserRole.FACULTY,
            branch = "IT"
        ),
        User(
            userId = "cr_i1",
            registrationNumber = "24B01A12I1",
            name = "VADAPARTHI HEMA LATHA (CR - I1)",
            passwordHash = hashPassword("Cr@123"),
            role = UserRole.CR,
            academicYear = "3rd Year",
            branch = "IT",
            section = "Section C"
        ),
        User(
            userId = "cr_f7",
            registrationNumber = "24B01A12F7",
            name = "SEELAM LOHITHA RANI (CR - F7)",
            passwordHash = hashPassword("Cr@123"),
            role = UserRole.CR,
            academicYear = "3rd Year",
            branch = "IT",
            section = "Section C"
        )
    )

    // STRICT REQUIREMENT: Exact 64 students ONLY for 3rd Year -> IT -> Section C.
    // All other year, branch, and section combinations remain empty.
    val INITIAL_3RD_YEAR_IT_C_STUDENTS = listOf(
        Student("3Y_IT_C_24B01A12D2", 1, "24B01A12D2", "PERURU KOUSALYA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12D3", 2, "24B01A12D3", "PIPPARAPALLI NIRMALA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12D4", 3, "24B01A12D4", "POLISETI SRAVYA NAGA LAKSHMI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12D5", 4, "24B01A12D5", "POTNURU SUSHMA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12D6", 5, "24B01A12D6", "PUDI ANUSHKA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12D7", 6, "24B01A12D7", "PULAVARTHI BHANU PRANATHI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12D8", 7, "24B01A12D8", "PULLEPU TAPASWI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12D9", 8, "24B01A12D9", "PUSHYATHA SRI VAISHNAVI KORLA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12E0", 9, "24B01A12E0", "PYDIMARRI SRIVALLI NAGA VAISHNAVI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12E1", 10, "24B01A12E1", "RACHAMADUGU HASINI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12E2", 11, "24B01A12E2", "RACHAMADUGU LIKITHA HASINI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12E3", 12, "24B01A12E3", "RATNALA RENUKA DEVI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12E4", 13, "24B01A12E4", "RAVIKRINDI RAAGA VARSHINI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12E5", 14, "24B01A12E5", "REGANTI GAYATHRI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12E6", 15, "24B01A12E6", "REKKALA SIREESHA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12E7", 16, "24B01A12E7", "RUDRARAJU JYOTSNA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12E8", 17, "24B01A12E8", "SAHITHI ACHYUTHA ISHWARYA KALLA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12E9", 18, "24B01A12E9", "SAI NAGA SUJITHA NAKKA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12F0", 19, "24B01A12F0", "SAKALA SPURTHI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12F1", 20, "24B01A12F1", "SALA UDAYA VENKATESWARI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12F2", 21, "24B01A12F2", "SAMATHAM KAVYA JYOTSHNA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12F3", 22, "24B01A12F3", "SAMIREDDI VARSHINI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12F4", 23, "24B01A12F4", "SAMUDALAPALEM APURVA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12F5", 24, "24B01A12F5", "SANTOSHI INDUGULA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12F6", 25, "24B01A12F6", "SATTI TARUNIKA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12F7", 26, "24B01A12F7", "SEELAM LOHITHA RANI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12F8", 27, "24B01A12F8", "SHAIK AFRIN", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12F9", 28, "24B01A12F9", "SHAIK AISHA THASIM", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12G0", 29, "24B01A12G0", "SHAIK CHINNA FAREEDAGARI SANA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12G1", 30, "24B01A12G1", "SHAIK KOWSAR", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12G2", 31, "24B01A12G2", "SHAIK MEHARUNNISA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12G3", 32, "24B01A12G3", "SHAIK NAZMA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12G4", 33, "24B01A12G4", "SHAIK SONA KOUSAR", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12G5", 34, "24B01A12G5", "SHAIK VENENSHA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12G6", 35, "24B01A12G6", "SOMU SRAVYA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12G7", 36, "24B01A12G7", "SRIKHAKOLLU NAVYA SRI LAKSHMI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12G8", 37, "24B01A12G8", "SRIREDDY HEMASRI MADHURI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12G9", 38, "24B01A12G9", "SWETHA NANDHINI LAKKIMSETTY", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12H0", 39, "24B01A12H0", "TANETI PRANITHA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12H1", 40, "24B01A12H1", "TANGUDU SHIVANI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12H2", 41, "24B01A12H2", "TEJASWI KUKUNURI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12H3", 42, "24B01A12H3", "TELAGAMSETTI GNANA SAMHITHA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12H4", 43, "24B01A12H4", "TERLU GEETA MADHURI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12H5", 44, "24B01A12H5", "THOKALA PAVANI VIJAYA SYAMALA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12H6", 45, "24B01A12H6", "THOTA HARSHITHA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12H7", 46, "24B01A12H7", "THOTAKURA RUPA SAI LAKSHMI RISHITHA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12H8", 47, "24B01A12H8", "TOTA BHUVANASRI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12H9", 48, "24B01A12H9", "TUMMALA PENTA MAHESWARI SRAVYA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12I0", 49, "24B01A12I0", "UNDAVILLI AMRUTA SAI SURYA GEETIKA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12I1", 50, "24B01A12I1", "VADAPARTHI HEMA LATHA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12I2", 51, "24B01A12I2", "VALLABHANI KRISHMA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12I3", 52, "24B01A12I3", "VALLURI DEVI DEEPIKA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12I4", 53, "24B01A12I4", "VARADA HARITHA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12I5", 54, "24B01A12I5", "VASKURI RADHI SRUJANA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12I6", 55, "24B01A12I6", "VASKURI SANDHYA KRISHNA SRI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12I7", 56, "24B01A12I7", "VEMA TEJASAI VYSHNAVI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12I8", 57, "24B01A12I8", "VINDULA SRUTHI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12I9", 58, "24B01A12I9", "VUTA GEETHA SRIVANI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12J0", 59, "24B01A12J0", "YADALA YASO SREENIDHI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12J1", 60, "24B01A12J1", "YALLA SINDHU SRI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12J2", 61, "24B01A12J2", "YANNAMSETTI SIRISHA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12J3", 62, "24B01A12J3", "YEDIDA TEJASWINI", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12J4", 63, "24B01A12J4", "YENUMULA MOUNIKA", "3rd Year", "IT", "Section C"),
        Student("3Y_IT_C_24B01A12J5", 64, "24B01A12J5", "YERUVA PRANATHI", "3rd Year", "IT", "Section C")
    )
}
