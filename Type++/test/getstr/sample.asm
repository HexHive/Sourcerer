
sample.out:     file format elf64-x86-64


Disassembly of section .init:

0000000000401000 <_init>:
  401000:	f3 0f 1e fa          	endbr64 
  401004:	48 83 ec 08          	sub    rsp,0x8
  401008:	48 8b 05 e9 2f 00 00 	mov    rax,QWORD PTR [rip+0x2fe9]        # 403ff8 <__gmon_start__>
  40100f:	48 85 c0             	test   rax,rax
  401012:	74 02                	je     401016 <_init+0x16>
  401014:	ff d0                	call   rax
  401016:	48 83 c4 08          	add    rsp,0x8
  40101a:	c3                   	ret    

Disassembly of section .plt:

0000000000401020 <.plt>:
  401020:	ff 35 e2 2f 00 00    	push   QWORD PTR [rip+0x2fe2]        # 404008 <_GLOBAL_OFFSET_TABLE_+0x8>
  401026:	ff 25 e4 2f 00 00    	jmp    QWORD PTR [rip+0x2fe4]        # 404010 <_GLOBAL_OFFSET_TABLE_+0x10>
  40102c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000401030 <printf@plt>:
  401030:	ff 25 e2 2f 00 00    	jmp    QWORD PTR [rip+0x2fe2]        # 404018 <printf@GLIBC_2.2.5>
  401036:	68 00 00 00 00       	push   0x0
  40103b:	e9 e0 ff ff ff       	jmp    401020 <.plt>

0000000000401040 <_ZNKSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE5c_strEv@plt>:
  401040:	ff 25 da 2f 00 00    	jmp    QWORD PTR [rip+0x2fda]        # 404020 <_ZNKSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE5c_strEv@GLIBCXX_3.4.21>
  401046:	68 01 00 00 00       	push   0x1
  40104b:	e9 d0 ff ff ff       	jmp    401020 <.plt>

0000000000401050 <_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC1EOS4_@plt>:
  401050:	ff 25 d2 2f 00 00    	jmp    QWORD PTR [rip+0x2fd2]        # 404028 <_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC1EOS4_@GLIBCXX_3.4.21>
  401056:	68 02 00 00 00       	push   0x2
  40105b:	e9 c0 ff ff ff       	jmp    401020 <.plt>

0000000000401060 <_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED1Ev@plt>:
  401060:	ff 25 ca 2f 00 00    	jmp    QWORD PTR [rip+0x2fca]        # 404030 <_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED1Ev@GLIBCXX_3.4.21>
  401066:	68 03 00 00 00       	push   0x3
  40106b:	e9 b0 ff ff ff       	jmp    401020 <.plt>

0000000000401070 <_ZNSaIcED1Ev@plt>:
  401070:	ff 25 c2 2f 00 00    	jmp    QWORD PTR [rip+0x2fc2]        # 404038 <_ZNSaIcED1Ev@GLIBCXX_3.4>
  401076:	68 04 00 00 00       	push   0x4
  40107b:	e9 a0 ff ff ff       	jmp    401020 <.plt>

0000000000401080 <_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC1EPKcRKS3_@plt>:
  401080:	ff 25 ba 2f 00 00    	jmp    QWORD PTR [rip+0x2fba]        # 404040 <_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC1EPKcRKS3_@GLIBCXX_3.4.21>
  401086:	68 05 00 00 00       	push   0x5
  40108b:	e9 90 ff ff ff       	jmp    401020 <.plt>

0000000000401090 <__gxx_personality_v0@plt>:
  401090:	ff 25 b2 2f 00 00    	jmp    QWORD PTR [rip+0x2fb2]        # 404048 <__gxx_personality_v0@CXXABI_1.3>
  401096:	68 06 00 00 00       	push   0x6
  40109b:	e9 80 ff ff ff       	jmp    401020 <.plt>

00000000004010a0 <_Unwind_Resume@plt>:
  4010a0:	ff 25 aa 2f 00 00    	jmp    QWORD PTR [rip+0x2faa]        # 404050 <_Unwind_Resume@GCC_3.0>
  4010a6:	68 07 00 00 00       	push   0x7
  4010ab:	e9 70 ff ff ff       	jmp    401020 <.plt>

00000000004010b0 <_ZNSaIcEC1Ev@plt>:
  4010b0:	ff 25 a2 2f 00 00    	jmp    QWORD PTR [rip+0x2fa2]        # 404058 <_ZNSaIcEC1Ev@GLIBCXX_3.4>
  4010b6:	68 08 00 00 00       	push   0x8
  4010bb:	e9 60 ff ff ff       	jmp    401020 <.plt>

Disassembly of section .text:

00000000004010c0 <_start>:
  4010c0:	f3 0f 1e fa          	endbr64 
  4010c4:	31 ed                	xor    ebp,ebp
  4010c6:	49 89 d1             	mov    r9,rdx
  4010c9:	5e                   	pop    rsi
  4010ca:	48 89 e2             	mov    rdx,rsp
  4010cd:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
  4010d1:	50                   	push   rax
  4010d2:	54                   	push   rsp
  4010d3:	49 c7 c0 20 13 40 00 	mov    r8,0x401320
  4010da:	48 c7 c1 b0 12 40 00 	mov    rcx,0x4012b0
  4010e1:	48 c7 c7 40 12 40 00 	mov    rdi,0x401240
  4010e8:	ff 15 02 2f 00 00    	call   QWORD PTR [rip+0x2f02]        # 403ff0 <__libc_start_main@GLIBC_2.2.5>
  4010ee:	f4                   	hlt    
  4010ef:	90                   	nop

00000000004010f0 <_dl_relocate_static_pie>:
  4010f0:	f3 0f 1e fa          	endbr64 
  4010f4:	c3                   	ret    
  4010f5:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  4010fc:	00 00 00 
  4010ff:	90                   	nop

0000000000401100 <deregister_tm_clones>:
  401100:	b8 70 40 40 00       	mov    eax,0x404070
  401105:	48 3d 70 40 40 00    	cmp    rax,0x404070
  40110b:	74 13                	je     401120 <deregister_tm_clones+0x20>
  40110d:	b8 00 00 00 00       	mov    eax,0x0
  401112:	48 85 c0             	test   rax,rax
  401115:	74 09                	je     401120 <deregister_tm_clones+0x20>
  401117:	bf 70 40 40 00       	mov    edi,0x404070
  40111c:	ff e0                	jmp    rax
  40111e:	66 90                	xchg   ax,ax
  401120:	c3                   	ret    
  401121:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  401128:	00 00 00 00 
  40112c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000401130 <register_tm_clones>:
  401130:	be 70 40 40 00       	mov    esi,0x404070
  401135:	48 81 ee 70 40 40 00 	sub    rsi,0x404070
  40113c:	48 89 f0             	mov    rax,rsi
  40113f:	48 c1 ee 3f          	shr    rsi,0x3f
  401143:	48 c1 f8 03          	sar    rax,0x3
  401147:	48 01 c6             	add    rsi,rax
  40114a:	48 d1 fe             	sar    rsi,1
  40114d:	74 11                	je     401160 <register_tm_clones+0x30>
  40114f:	b8 00 00 00 00       	mov    eax,0x0
  401154:	48 85 c0             	test   rax,rax
  401157:	74 07                	je     401160 <register_tm_clones+0x30>
  401159:	bf 70 40 40 00       	mov    edi,0x404070
  40115e:	ff e0                	jmp    rax
  401160:	c3                   	ret    
  401161:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  401168:	00 00 00 00 
  40116c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000401170 <__do_global_dtors_aux>:
  401170:	f3 0f 1e fa          	endbr64 
  401174:	80 3d f5 2e 00 00 00 	cmp    BYTE PTR [rip+0x2ef5],0x0        # 404070 <__TMC_END__>
  40117b:	75 13                	jne    401190 <__do_global_dtors_aux+0x20>
  40117d:	55                   	push   rbp
  40117e:	48 89 e5             	mov    rbp,rsp
  401181:	e8 7a ff ff ff       	call   401100 <deregister_tm_clones>
  401186:	c6 05 e3 2e 00 00 01 	mov    BYTE PTR [rip+0x2ee3],0x1        # 404070 <__TMC_END__>
  40118d:	5d                   	pop    rbp
  40118e:	c3                   	ret    
  40118f:	90                   	nop
  401190:	c3                   	ret    
  401191:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  401198:	00 00 00 00 
  40119c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

00000000004011a0 <frame_dummy>:
  4011a0:	f3 0f 1e fa          	endbr64 
  4011a4:	eb 8a                	jmp    401130 <register_tm_clones>
  4011a6:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  4011ad:	00 00 00 

00000000004011b0 <_Z3getB5cxx11v>:
  4011b0:	55                   	push   rbp
  4011b1:	48 89 e5             	mov    rbp,rsp
  4011b4:	48 83 ec 60          	sub    rsp,0x60
  4011b8:	48 89 7d a8          	mov    QWORD PTR [rbp-0x58],rdi
  4011bc:	48 89 f9             	mov    rcx,rdi
  4011bf:	48 89 4d b0          	mov    QWORD PTR [rbp-0x50],rcx
  4011c3:	48 89 7d f8          	mov    QWORD PTR [rbp-0x8],rdi
  4011c7:	48 8d 7d d0          	lea    rdi,[rbp-0x30]
  4011cb:	48 89 7d b8          	mov    QWORD PTR [rbp-0x48],rdi
  4011cf:	e8 dc fe ff ff       	call   4010b0 <_ZNSaIcEC1Ev@plt>
  4011d4:	48 8b 55 b8          	mov    rdx,QWORD PTR [rbp-0x48]
  4011d8:	be 04 20 40 00       	mov    esi,0x402004
  4011dd:	48 8d 7d d8          	lea    rdi,[rbp-0x28]
  4011e1:	e8 9a fe ff ff       	call   401080 <_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC1EPKcRKS3_@plt>
  4011e6:	e9 00 00 00 00       	jmp    4011eb <_Z3getB5cxx11v+0x3b>
  4011eb:	48 8d 7d d0          	lea    rdi,[rbp-0x30]
  4011ef:	e8 7c fe ff ff       	call   401070 <_ZNSaIcED1Ev@plt>
  4011f4:	48 8b 7d a8          	mov    rdi,QWORD PTR [rbp-0x58]
  4011f8:	48 8d 75 d8          	lea    rsi,[rbp-0x28]
  4011fc:	e8 4f fe ff ff       	call   401050 <_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC1EOS4_@plt>
  401201:	48 8d 7d d8          	lea    rdi,[rbp-0x28]
  401205:	e8 56 fe ff ff       	call   401060 <_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED1Ev@plt>
  40120a:	48 8b 45 b0          	mov    rax,QWORD PTR [rbp-0x50]
  40120e:	48 83 c4 60          	add    rsp,0x60
  401212:	5d                   	pop    rbp
  401213:	c3                   	ret    
  401214:	48 89 c1             	mov    rcx,rax
  401217:	89 d0                	mov    eax,edx
  401219:	48 89 4d c8          	mov    QWORD PTR [rbp-0x38],rcx
  40121d:	89 45 c4             	mov    DWORD PTR [rbp-0x3c],eax
  401220:	48 8d 7d d0          	lea    rdi,[rbp-0x30]
  401224:	e8 47 fe ff ff       	call   401070 <_ZNSaIcED1Ev@plt>
  401229:	48 8b 7d c8          	mov    rdi,QWORD PTR [rbp-0x38]
  40122d:	e8 6e fe ff ff       	call   4010a0 <_Unwind_Resume@plt>
  401232:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  401239:	00 00 00 
  40123c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000401240 <main>:
  401240:	55                   	push   rbp
  401241:	48 89 e5             	mov    rbp,rsp
  401244:	48 83 ec 40          	sub    rsp,0x40
  401248:	48 8d 7d e0          	lea    rdi,[rbp-0x20]
  40124c:	48 89 7d c8          	mov    QWORD PTR [rbp-0x38],rdi
  401250:	e8 5b ff ff ff       	call   4011b0 <_Z3getB5cxx11v>
  401255:	48 8b 7d c8          	mov    rdi,QWORD PTR [rbp-0x38]
  401259:	e8 e2 fd ff ff       	call   401040 <_ZNKSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE5c_strEv@plt>
  40125e:	48 89 c6             	mov    rsi,rax
  401261:	bf 09 20 40 00       	mov    edi,0x402009
  401266:	31 c0                	xor    eax,eax
  401268:	e8 c3 fd ff ff       	call   401030 <printf@plt>
  40126d:	e9 00 00 00 00       	jmp    401272 <main+0x32>
  401272:	48 8d 7d e0          	lea    rdi,[rbp-0x20]
  401276:	e8 e5 fd ff ff       	call   401060 <_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED1Ev@plt>
  40127b:	31 c0                	xor    eax,eax
  40127d:	48 83 c4 40          	add    rsp,0x40
  401281:	5d                   	pop    rbp
  401282:	c3                   	ret    
  401283:	48 89 c1             	mov    rcx,rax
  401286:	89 d0                	mov    eax,edx
  401288:	48 89 4d d8          	mov    QWORD PTR [rbp-0x28],rcx
  40128c:	89 45 d4             	mov    DWORD PTR [rbp-0x2c],eax
  40128f:	48 8d 7d e0          	lea    rdi,[rbp-0x20]
  401293:	e8 c8 fd ff ff       	call   401060 <_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED1Ev@plt>
  401298:	48 8b 7d d8          	mov    rdi,QWORD PTR [rbp-0x28]
  40129c:	e8 ff fd ff ff       	call   4010a0 <_Unwind_Resume@plt>
  4012a1:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  4012a8:	00 00 00 
  4012ab:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

00000000004012b0 <__libc_csu_init>:
  4012b0:	f3 0f 1e fa          	endbr64 
  4012b4:	41 57                	push   r15
  4012b6:	4c 8d 3d 23 2b 00 00 	lea    r15,[rip+0x2b23]        # 403de0 <__frame_dummy_init_array_entry>
  4012bd:	41 56                	push   r14
  4012bf:	49 89 d6             	mov    r14,rdx
  4012c2:	41 55                	push   r13
  4012c4:	49 89 f5             	mov    r13,rsi
  4012c7:	41 54                	push   r12
  4012c9:	41 89 fc             	mov    r12d,edi
  4012cc:	55                   	push   rbp
  4012cd:	48 8d 2d 14 2b 00 00 	lea    rbp,[rip+0x2b14]        # 403de8 <__do_global_dtors_aux_fini_array_entry>
  4012d4:	53                   	push   rbx
  4012d5:	4c 29 fd             	sub    rbp,r15
  4012d8:	48 83 ec 08          	sub    rsp,0x8
  4012dc:	e8 1f fd ff ff       	call   401000 <_init>
  4012e1:	48 c1 fd 03          	sar    rbp,0x3
  4012e5:	74 1f                	je     401306 <__libc_csu_init+0x56>
  4012e7:	31 db                	xor    ebx,ebx
  4012e9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  4012f0:	4c 89 f2             	mov    rdx,r14
  4012f3:	4c 89 ee             	mov    rsi,r13
  4012f6:	44 89 e7             	mov    edi,r12d
  4012f9:	41 ff 14 df          	call   QWORD PTR [r15+rbx*8]
  4012fd:	48 83 c3 01          	add    rbx,0x1
  401301:	48 39 dd             	cmp    rbp,rbx
  401304:	75 ea                	jne    4012f0 <__libc_csu_init+0x40>
  401306:	48 83 c4 08          	add    rsp,0x8
  40130a:	5b                   	pop    rbx
  40130b:	5d                   	pop    rbp
  40130c:	41 5c                	pop    r12
  40130e:	41 5d                	pop    r13
  401310:	41 5e                	pop    r14
  401312:	41 5f                	pop    r15
  401314:	c3                   	ret    
  401315:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  40131c:	00 00 00 00 

0000000000401320 <__libc_csu_fini>:
  401320:	f3 0f 1e fa          	endbr64 
  401324:	c3                   	ret    

Disassembly of section .fini:

0000000000401328 <_fini>:
  401328:	f3 0f 1e fa          	endbr64 
  40132c:	48 83 ec 08          	sub    rsp,0x8
  401330:	48 83 c4 08          	add    rsp,0x8
  401334:	c3                   	ret    
