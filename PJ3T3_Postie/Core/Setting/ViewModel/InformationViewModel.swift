//
//  InformationViewModel.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 7/7/24.
//

import SwiftUI

class InformationViewModel: ObservableObject {
    @Published var columns = Array(repeating: GridItem(.flexible(), spacing: 9), count: 2)
    
    struct PersonGridView: View {
        var person: Person
        
        var body: some View {
    //        Link(destination: URL(string: person.link)!) {
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .foregroundStyle(person.color)
                            .shadow(color: .black, radius: 0.8)
                        
                        VStack {
                            Text(person.name)
                                .bold()
                            
                            Text(person.subtitle)
                                .font(.footnote)
                            
                            Image(person.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                        }
                        .foregroundStyle(.postieWhite)
                    }
                }
    //        }
        }
    }

    struct TermOfUserView: View {
        @AppStorage("isThemeGroupButton") private var isThemeGroupButton: Int = 0
        
        var body: some View {
            ZStack {
                postieColors.backGroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("제1조 (목적)\n")
                            .bold()
                        
                        Text("""
                            이 약관은 팀포스티 (이하 "회사"라 함)이 운영하는 포스티 및 관련 서비스(이하 "서비스"라 함)의 이용 조건 및 절차, 이용자와 회사의 권리, 의무, 책임사항, 서비스 이용에 대한 기본적인 사항을 규정함을 목적으로 합니다.\n
                            """)
                            .font(.subheadline)
                        
                        Text("제2조 (정의)\n")
                            .bold()
                        
                        Text("""
                             이 약관에서 사용하는 용어의 정의는 다음과 같습니다.
                             1. "서비스"라 함은 회사가 모바일 기기를 통해 이용자에게 제공하는 포스티 관련 제반 서비스를 의미합니다.
                             2. "이용자"라 함은 회사의 "서비스"에 접속하여 이 약관에 따라 회사가 제공하는 "서비스"를 이용하는 모든 회원 및 비회원을 말합니다.
                             3. "회원"이라 함은 "서비스"에 회원등록을 한 자로서, 계속적으로 "회사"가 제공하는 "서비스"를 이용할 수 있는 자를 말합니다.\n
                             """)
                            .font(.subheadline)
                        
                        Text("제3조 (이용계약의 성립)\n")
                            .bold()
                        
                        Text("""
                            이용계약은 이용자가 약관의 내용에 대해 동의하고, 회사가 정한 절차에 따라 이용신청을 하며, 회사가 이를 승낙함으로써 체결됩니다.\n
                            """)
                            .font(.subheadline)
                        
                        Text("제4조 (서비스의 제공 및 변경)\n")
                            .bold()
                        
                        Text("""
                             회사는 다음과 같은 서비스를 제공합니다.
                             서비스의 구체적인 내용은 회사가 운영하는 앱 또는 웹사이트 등을 통해 이용자에게 공지합니다.
                             회사는 필요한 경우 서비스의 내용을 변경할 수 있으며, 이러한 변경 사항은 앱 내 또는 회사의 웹사이트를 통해 공지됩니다.\n
                             """)
                            .font(.subheadline)
                        
                        Text("제5조 (이용료 및 결제)\n")
                            .bold()
                        
                        Text("""
                             서비스의 이용료와 결제 방법, 환불 정책 등에 대한 사항은 회사가 별도로 정하는 바에 따릅니다.
                             유료 서비스 이용 시 이용자는 회사가 정한 결제 수단을 통해 이용료를 납부해야 합니다.\n
                             """)
                            .font(.subheadline)
                        
                        Text("제6조 (회원가입)\n")
                            .bold()
                        
                        Text("""
                             이용자는 회사가 정한 가입 양식에 따라 회원정보를 기입하고, 이 약관에 동의한다는 의사표시를 함으로써 회원가입을 신청할 수 있습니다.
                             회사는 이용자의 신청에 대해 서비스 이용을 승낙할 수 있습니다.\n
                             """)
                            .font(.subheadline)
                        
                        Text("제7조 (회원의 의무)\n")
                            .bold()
                        
                        Text("""
                            회원은 개인정보 변경 시 즉시 이를 업데이트하고, 서비스 이용과 관련하여 발생하는 모든 책임을 집니다.
                            또한, 회원은 이 약관 및 관련 법령을 준수해야 합니다.\n
                            """)
                            .font(.subheadline)
                        
                        Text("제8조 (회사의 의무)\n")
                            .bold()
                        
                        Text("""
                             회사는 안정적인 서비스 제공을 위해 노력하며, 회원의 개인정보를 보호하기 위해 관련 법령에 따라 적절한 조치를 취합니다.\n
                             """)
                        .font(.subheadline)
                        
                        Text("제9조 (서비스 이용 제한)\n")
                            .bold()
                        
                        Text("""
                            회사는 회원이 이 약관의 규정을 위반하거나 서비스의 정상적인 운영을 방해하는 경우, 서비스 이용을 제한하거나 회원 자격을 상실시킬 수 있습니다.\n
                            """)
                        .font(.subheadline)
                        
                        Text("제10조 (저작권 및 지적재산권)\n")
                            .bold()
                        
                        Text("""
                            서비스와 관련된 저작물 및 콘텐츠에 대한 저작권은 회사 또는 해당 저작권자에게 있습니다.
                            이용자는 서비스를 이용함으로써 얻은 정보를 회사의 사전 승인 없이 복제, 배포, 방송 등의 방법으로 사용할 수 없습니다.\n
                            """)
                        .font(.subheadline)
                        
                        Text("제11조 (면책사항)\n")
                            .bold()
                        
                        Text("회사는 천재지변, 전쟁, 서비스 이용자의 고의 또는 과실로 인한 서비스 장애 등 불가항력적 사유로 인해 서비스를 제공할 수 없는 경우에는 책임이 면제됩니다.\n")
                            .font(.subheadline)
                        
                        Text("제12조 (분쟁 해결)\n")
                            .bold()
                        
                        Text("""
                            서비스 이용과 관련하여 분쟁이 발생한 경우, 회사와 이용자는 상호 협의 하에 분쟁을 해결하기 위해 노력합니다.
                            협의 하에 해결되지 않는 경우, 관련 법령에 따른 절차를 통해 해결합니다.\n
                            """)
                        .font(.subheadline)
                        
                        Text("제13조 (약관의 변경)\n")
                            .bold()
                        
                        Text("""
                            회사는 필요한 경우 약관을 변경할 수 있으며, 변경된 약관은 지정된 방법으로 이용자에게 공지됩니다.
                            변경된 약관은 공지 후 일정 기간이 경과한 뒤에 효력이 발생합니다.\n
                            """)
                        .font(.subheadline)
                        
                        Text("제14조 (기타)\n")
                            .bold()
                        
                        Text("""
                            본 약관에 명시되지 않은 사항에 대해서는 관련 법령 또는 상관례에 따릅니다.\n
                            """)
                        .font(.subheadline)
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    Text("이용약관")
                        .bold()
                        .foregroundStyle(postieColors.tintColor)
                }
            }
            .toolbarBackground(postieColors.backGroundColor, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
