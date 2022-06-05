#include "mainwidget.h"
#include "ui_mainwidget.h"

#include <QDebug>

#include "basic/src/lib.rs.h"
#include "second/src/lib.rs.h"
#include "foo/src/lib.rs.h"
#include "bar/src/lib.rs.h"


extern "C" {
    int32_t rust_extern_c_integer();
}

MainWidget::MainWidget(QWidget *parent)
    : QWidget(parent)
      , ui(new Ui::MainWidget)
{
    ui->setupUi(this);

    testRust();
}

MainWidget::~MainWidget()
{
    delete ui;
}

void MainWidget::testRust() {
    std::vector<std::string> vec {
        "1", "2", "3", "4", "5", "6", "7"
    };
    auto intVec = basic::toIntVector(vec);
    qDebug() << "Int Vector Size: " << intVec.size();
    for(auto item : intVec) {
        qDebug() << "Item: " << item;
    }

    auto rs = basic::getRustStruct();
    qDebug() << "x: " << rs.x << " y: " << rs.y << " z: " << rs.z.c_str();

    int i = rust_extern_c_integer();
    qDebug() << "Rust extern c: " << i;

    auto s1 = works::sayHi("SayHi from C++");
    qDebug() << "SayHi from works: " << s1.c_str();

    auto s2 = works::greeting("Greeting from C++");
    qDebug() << "Greeting from works: " << s2.c_str();

    rust::String s = second::to_rust_string("hello world");
    qDebug() << "to_rust_string： " << s.c_str();
}

