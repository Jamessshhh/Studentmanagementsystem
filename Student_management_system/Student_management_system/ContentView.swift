//
//  ContentView.swift
//  Student_management_system
//
//  Created by Ritesh Mahara on 12/02/25.
//

//
//  StudentManagementSystemApp.swift
//  StudentManagementSystem
//
//  Created by Ritesh Mahara on 11/09/24.
//

import SwiftUI

// Step 1: Define a Student structure
struct Student: Identifiable {
    var id = UUID()
    var regNo: String
    var name: String
    var gender: String
    var grade: Int
    var phone: String
    var email: String
}

// Step 2: ViewModel for managing students
class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var averageGrade: Double = 0.0
    @Published var sortAscending: Bool = true // Track sorting order

    // Generate unique Registration Number
    private func generateRegNo() -> String {
        return "STU\(Int.random(in: 1000...9999))"
    }
    
    // Add a new student
    func addStudent(name: String, gender: String, grade: Int, phone: String, email: String) {
        let newStudent = Student(
            regNo: generateRegNo(),
            name: name,
            gender: gender,
            grade: grade,
            phone: phone,
            email: email
        )
        students.append(newStudent)
        calculateAverageGrade()
        sortStudents()
    }
    
    // Edit student details
    func editStudent(student: Student, newName: String, newGender: String, newGrade: Int, newPhone: String, newEmail: String) {
        if let index = students.firstIndex(where: { $0.id == student.id }) {
            students[index].name = newName
            students[index].gender = newGender
            students[index].grade = newGrade
            students[index].phone = newPhone
            students[index].email = newEmail
            calculateAverageGrade()
            sortStudents()
        }
    }

    // Delete a student
    func deleteStudent(student: Student) {
        students.removeAll { $0.id == student.id }
        calculateAverageGrade()
    }

    // Calculate the average grade
    func calculateAverageGrade() {
        let total = students.reduce(0) { $0 + $1.grade }
        averageGrade = students.isEmpty ? 0.0 : Double(total) / Double(students.count)
    }

    // Sort students based on marks
    func sortStudents() {
        if sortAscending {
            students.sort { $0.grade < $1.grade }
        } else {
            students.sort { $0.grade > $1.grade }
        }
    }

    // Toggle sorting order
    func toggleSortingOrder() {
        sortAscending.toggle()
        sortStudents()
    }
}

// Step 3: Main View
struct ContentView: View {
    @StateObject var viewModel = StudentViewModel()
    @State private var showAddStudentForm = false
    @State private var selectedStudent: Student?

    var body: some View {
        NavigationView {
            VStack {
                // Sorting Button
                HStack {
                    Button(action: {
                        viewModel.toggleSortingOrder()
                    }) {
                        HStack {
                            Text("Sort by Marks")
                            Image(systemName: viewModel.sortAscending ? "arrow.up" : "arrow.down")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }

                // Student List
                List {
                    Section(header: Text("Students List").font(.headline)) {
                        ForEach(viewModel.students) { student in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(student.name).font(.headline)
                                Text("Reg No: \(student.regNo)").font(.subheadline).foregroundColor(.gray)
                                Text("Gender: \(student.gender)").font(.subheadline)
                                Text("Grade: \(student.grade)").font(.subheadline).foregroundColor(.blue)
                                Text("Phone: \(student.phone)").font(.subheadline).foregroundColor(.green)
                                Text("Email: \(student.email)").font(.subheadline).foregroundColor(.purple)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                            .onTapGesture {
                                selectedStudent = student
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { viewModel.deleteStudent(student: viewModel.students[$0]) }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())

                // Add Student Button
                Button(action: {
                    showAddStudentForm.toggle()
                }) {
                    Text("Add New Student")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                // Display Average Grade
                Text("Average Grade: \(viewModel.averageGrade, specifier: "%.2f")")
                    .font(.title3)
                    .padding()
            }
            .navigationTitle("Student Management")
            .sheet(isPresented: $showAddStudentForm) {
                AddStudentForm(viewModel: viewModel, showForm: $showAddStudentForm)
            }
        }
    }
}

// Step 4: Add Student Form
struct AddStudentForm: View {
    @ObservedObject var viewModel: StudentViewModel
    @Binding var showForm: Bool
    @State private var name: String = ""
    @State private var gender: String = "Male"
    @State private var grade: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Details")) {
                    TextField("Student Name", text: $name)
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Academic Details")) {
                    TextField("Grade", text: $grade)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                }
                
                Button("Add Student") {
                    if !name.isEmpty, let gradeInt = Int(grade), !phone.isEmpty, !email.isEmpty {
                        viewModel.addStudent(name: name, gender: gender, grade: gradeInt, phone: phone, email: email)
                        showForm = false
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("Add New Student")
            .navigationBarItems(trailing: Button("Cancel") {
                showForm = false
            })
        }
    }
}

// Step 5: Main App Entry Point
@main
struct StudentManagementSystemApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
