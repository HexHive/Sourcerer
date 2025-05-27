; ModuleID = 'secondmodule.cpp'
source_filename = "secondmodule.cpp"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.ReallyReallyFakeDerivedType = type { %struct.ReallyFakeDerivedType.base, i32 }
%struct.ReallyFakeDerivedType.base = type <{ %struct.FakeDerivedType, i32 }>
%struct.FakeDerivedType = type { %struct.BaseDerivedType }
%struct.BaseDerivedType = type { %struct.BaseType, i8, i8, i8, i8, i8, i8, i8, i8 }
%struct.BaseType = type { i32 (...)**, i64, [20 x i32] }
%struct.ReallyFakeDerivedType = type <{ %struct.FakeDerivedType, i32, [4 x i8] }>

$_ZN27ReallyReallyFakeDerivedTypeC2Ev = comdat any

$_ZN21ReallyFakeDerivedTypeC2Ev = comdat any

$_ZN15FakeDerivedTypeC2Ev = comdat any

$_ZN15BaseDerivedTypeC2Ev = comdat any

$_ZN8BaseTypeC2Ev = comdat any

$_ZTV27ReallyReallyFakeDerivedType = comdat any

$_ZTS27ReallyReallyFakeDerivedType = comdat any

$_ZTS21ReallyFakeDerivedType = comdat any

$_ZTS15FakeDerivedType = comdat any

$_ZTS15BaseDerivedType = comdat any

$_ZTS8BaseType = comdat any

$_ZTI8BaseType = comdat any

$_ZTI15BaseDerivedType = comdat any

$_ZTI15FakeDerivedType = comdat any

$_ZTI21ReallyFakeDerivedType = comdat any

$_ZTI27ReallyReallyFakeDerivedType = comdat any

$_ZTV21ReallyFakeDerivedType = comdat any

$_ZTV15FakeDerivedType = comdat any

$_ZTV15BaseDerivedType = comdat any

$_ZTV8BaseType = comdat any

@_ZTV27ReallyReallyFakeDerivedType = linkonce_odr dso_local unnamed_addr constant { [2 x i8*] } { [2 x i8*] [i8* null, i8* bitcast ({ i8*, i8*, i8* }* @_ZTI27ReallyReallyFakeDerivedType to i8*)] }, comdat, align 8
@_ZTVN10__cxxabiv120__si_class_type_infoE = external dso_local global i8*
@_ZTS27ReallyReallyFakeDerivedType = linkonce_odr dso_local constant [30 x i8] c"27ReallyReallyFakeDerivedType\00", comdat, align 1
@_ZTS21ReallyFakeDerivedType = linkonce_odr dso_local constant [24 x i8] c"21ReallyFakeDerivedType\00", comdat, align 1
@_ZTS15FakeDerivedType = linkonce_odr dso_local constant [18 x i8] c"15FakeDerivedType\00", comdat, align 1
@_ZTS15BaseDerivedType = linkonce_odr dso_local constant [18 x i8] c"15BaseDerivedType\00", comdat, align 1
@_ZTVN10__cxxabiv117__class_type_infoE = external dso_local global i8*
@_ZTS8BaseType = linkonce_odr dso_local constant [10 x i8] c"8BaseType\00", comdat, align 1
@_ZTI8BaseType = linkonce_odr dso_local constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv117__class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([10 x i8], [10 x i8]* @_ZTS8BaseType, i32 0, i32 0) }, comdat, align 8
@_ZTI15BaseDerivedType = linkonce_odr dso_local constant { i8*, i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv120__si_class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([18 x i8], [18 x i8]* @_ZTS15BaseDerivedType, i32 0, i32 0), i8* bitcast ({ i8*, i8* }* @_ZTI8BaseType to i8*) }, comdat, align 8
@_ZTI15FakeDerivedType = linkonce_odr dso_local constant { i8*, i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv120__si_class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([18 x i8], [18 x i8]* @_ZTS15FakeDerivedType, i32 0, i32 0), i8* bitcast ({ i8*, i8*, i8* }* @_ZTI15BaseDerivedType to i8*) }, comdat, align 8
@_ZTI21ReallyFakeDerivedType = linkonce_odr dso_local constant { i8*, i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv120__si_class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @_ZTS21ReallyFakeDerivedType, i32 0, i32 0), i8* bitcast ({ i8*, i8*, i8* }* @_ZTI15FakeDerivedType to i8*) }, comdat, align 8
@_ZTI27ReallyReallyFakeDerivedType = linkonce_odr dso_local constant { i8*, i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv120__si_class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([30 x i8], [30 x i8]* @_ZTS27ReallyReallyFakeDerivedType, i32 0, i32 0), i8* bitcast ({ i8*, i8*, i8* }* @_ZTI21ReallyFakeDerivedType to i8*) }, comdat, align 8
@_ZTV21ReallyFakeDerivedType = linkonce_odr dso_local unnamed_addr constant { [2 x i8*] } { [2 x i8*] [i8* null, i8* bitcast ({ i8*, i8*, i8* }* @_ZTI21ReallyFakeDerivedType to i8*)] }, comdat, align 8
@_ZTV15FakeDerivedType = linkonce_odr dso_local unnamed_addr constant { [2 x i8*] } { [2 x i8*] [i8* null, i8* bitcast ({ i8*, i8*, i8* }* @_ZTI15FakeDerivedType to i8*)] }, comdat, align 8
@_ZTV15BaseDerivedType = linkonce_odr dso_local unnamed_addr constant { [2 x i8*] } { [2 x i8*] [i8* null, i8* bitcast ({ i8*, i8*, i8* }* @_ZTI15BaseDerivedType to i8*)] }, comdat, align 8
@_ZTV8BaseType = linkonce_odr dso_local unnamed_addr constant { [2 x i8*] } { [2 x i8*] [i8* null, i8* bitcast ({ i8*, i8* }* @_ZTI8BaseType to i8*)] }, comdat, align 8

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @_Z13usetypeSecondv() #0 {
entry:
  %objDerived = alloca %struct.ReallyReallyFakeDerivedType, align 8
  call void @_ZN27ReallyReallyFakeDerivedTypeC2Ev(%struct.ReallyReallyFakeDerivedType* %objDerived) #1
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr dso_local void @_ZN27ReallyReallyFakeDerivedTypeC2Ev(%struct.ReallyReallyFakeDerivedType* %this) unnamed_addr #0 comdat align 2 {
entry:
  %this.addr = alloca %struct.ReallyReallyFakeDerivedType*, align 8
  store %struct.ReallyReallyFakeDerivedType* %this, %struct.ReallyReallyFakeDerivedType** %this.addr, align 8
  %this1 = load %struct.ReallyReallyFakeDerivedType*, %struct.ReallyReallyFakeDerivedType** %this.addr, align 8
  %0 = bitcast %struct.ReallyReallyFakeDerivedType* %this1 to %struct.ReallyFakeDerivedType*
  call void @_ZN21ReallyFakeDerivedTypeC2Ev(%struct.ReallyFakeDerivedType* %0) #1
  %1 = bitcast %struct.ReallyReallyFakeDerivedType* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [2 x i8*] }, { [2 x i8*] }* @_ZTV27ReallyReallyFakeDerivedType, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %1, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr dso_local void @_ZN21ReallyFakeDerivedTypeC2Ev(%struct.ReallyFakeDerivedType* %this) unnamed_addr #0 comdat align 2 {
entry:
  %this.addr = alloca %struct.ReallyFakeDerivedType*, align 8
  store %struct.ReallyFakeDerivedType* %this, %struct.ReallyFakeDerivedType** %this.addr, align 8
  %this1 = load %struct.ReallyFakeDerivedType*, %struct.ReallyFakeDerivedType** %this.addr, align 8
  %0 = bitcast %struct.ReallyFakeDerivedType* %this1 to %struct.FakeDerivedType*
  call void @_ZN15FakeDerivedTypeC2Ev(%struct.FakeDerivedType* %0) #1
  %1 = bitcast %struct.ReallyFakeDerivedType* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [2 x i8*] }, { [2 x i8*] }* @_ZTV21ReallyFakeDerivedType, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %1, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr dso_local void @_ZN15FakeDerivedTypeC2Ev(%struct.FakeDerivedType* %this) unnamed_addr #0 comdat align 2 {
entry:
  %this.addr = alloca %struct.FakeDerivedType*, align 8
  store %struct.FakeDerivedType* %this, %struct.FakeDerivedType** %this.addr, align 8
  %this1 = load %struct.FakeDerivedType*, %struct.FakeDerivedType** %this.addr, align 8
  %0 = bitcast %struct.FakeDerivedType* %this1 to %struct.BaseDerivedType*
  call void @_ZN15BaseDerivedTypeC2Ev(%struct.BaseDerivedType* %0) #1
  %1 = bitcast %struct.FakeDerivedType* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [2 x i8*] }, { [2 x i8*] }* @_ZTV15FakeDerivedType, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %1, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr dso_local void @_ZN15BaseDerivedTypeC2Ev(%struct.BaseDerivedType* %this) unnamed_addr #0 comdat align 2 {
entry:
  %this.addr = alloca %struct.BaseDerivedType*, align 8
  store %struct.BaseDerivedType* %this, %struct.BaseDerivedType** %this.addr, align 8
  %this1 = load %struct.BaseDerivedType*, %struct.BaseDerivedType** %this.addr, align 8
  %0 = bitcast %struct.BaseDerivedType* %this1 to %struct.BaseType*
  call void @_ZN8BaseTypeC2Ev(%struct.BaseType* %0) #1
  %1 = bitcast %struct.BaseDerivedType* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [2 x i8*] }, { [2 x i8*] }* @_ZTV15BaseDerivedType, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %1, align 8
  %c1 = getelementptr inbounds %struct.BaseDerivedType, %struct.BaseDerivedType* %this1, i32 0, i32 1
  store i8 0, i8* %c1, align 8
  %c2 = getelementptr inbounds %struct.BaseDerivedType, %struct.BaseDerivedType* %this1, i32 0, i32 2
  store i8 0, i8* %c2, align 1
  %c3 = getelementptr inbounds %struct.BaseDerivedType, %struct.BaseDerivedType* %this1, i32 0, i32 3
  store i8 0, i8* %c3, align 2
  %c4 = getelementptr inbounds %struct.BaseDerivedType, %struct.BaseDerivedType* %this1, i32 0, i32 4
  store i8 0, i8* %c4, align 1
  %c5 = getelementptr inbounds %struct.BaseDerivedType, %struct.BaseDerivedType* %this1, i32 0, i32 5
  store i8 0, i8* %c5, align 4
  %c6 = getelementptr inbounds %struct.BaseDerivedType, %struct.BaseDerivedType* %this1, i32 0, i32 6
  store i8 0, i8* %c6, align 1
  %c7 = getelementptr inbounds %struct.BaseDerivedType, %struct.BaseDerivedType* %this1, i32 0, i32 7
  store i8 0, i8* %c7, align 2
  %c8 = getelementptr inbounds %struct.BaseDerivedType, %struct.BaseDerivedType* %this1, i32 0, i32 8
  store i8 0, i8* %c8, align 1
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr dso_local void @_ZN8BaseTypeC2Ev(%struct.BaseType* %this) unnamed_addr #0 comdat align 2 {
entry:
  %this.addr = alloca %struct.BaseType*, align 8
  store %struct.BaseType* %this, %struct.BaseType** %this.addr, align 8
  %this1 = load %struct.BaseType*, %struct.BaseType** %this.addr, align 8
  %0 = bitcast %struct.BaseType* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [2 x i8*] }, { [2 x i8*] }* @_ZTV8BaseType, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %0, align 8
  %longMember = getelementptr inbounds %struct.BaseType, %struct.BaseType* %this1, i32 0, i32 1
  store i64 0, i64* %longMember, align 8
  ret void
}

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.0 (git@github.com:HexHive/Typesafety-vtable.git 7ba546d21d39319cbadc89af2c9266e2516d480b)"}
