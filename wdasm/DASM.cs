
using System;
using System.Collections;
using System.IO;


namespace wdasm
{

	public enum TraceDirection 
	{
		Forward = 1,
		Back = 2
	}


	public struct ByteStruct 
	{
		public byte Data;
		public byte Flag;
	};

	public class OpcodeInfo
	{     
		private byte m_opcode;        /* 8-bit opcode value */
		private string m_name;        /* opcode name */
		private AddressMode m_mode;          /* addressing mode */
		private byte m_operands;

		public byte Opcode { get {return m_opcode;}	}
		public string Name { get {return m_name;} }
		public AddressMode Mode { get {return m_mode;} }
		public byte Operands { get {return m_operands;} }

		public OpcodeInfo (byte opcode, string name, AddressMode mode, byte operands) 
		{
			m_opcode = opcode;
			m_name = name;
			m_mode = mode;
			m_operands = operands;
		}
	};

	public enum AddressMode 
	{
		Illegal=1,
		Inherent=2,
		Direct=3,
		Extended=4,
		Relative=5,
		Indexed=6,
		Immediate=7
	}

	public enum TraceReturn 
	{
		// Trace Return codes
		Nothing,
		End,
		Add,
		Jump
	}

	/// <summary>
	/// Summary description for xDASM.
	/// </summary>
	public class DASM
	{

		OpcodeInfo[] Opcodes = { 
		new OpcodeInfo(0x00,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x01,"nop",AddressMode.Inherent,0),
		new OpcodeInfo(0x02,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x03,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x04,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x05,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x06,"tap",AddressMode.Inherent,0),
		new OpcodeInfo(0x07,"tpa",AddressMode.Inherent,0),
		new OpcodeInfo(0x08,"inx",AddressMode.Inherent,0),
		new OpcodeInfo(0x09,"dex",AddressMode.Inherent,0),
		new OpcodeInfo(0x0a,"clv",AddressMode.Inherent,0),
		new OpcodeInfo(0x0b,"sev",AddressMode.Inherent,0),
		new OpcodeInfo(0x0c,"clc",AddressMode.Inherent,0),
		new OpcodeInfo(0x0d,"sec",AddressMode.Inherent,0),
		new OpcodeInfo(0x0e,"cli",AddressMode.Inherent,0),
		new OpcodeInfo(0x0f,"sti",AddressMode.Inherent,0),

		new OpcodeInfo(0x10,"sba",AddressMode.Inherent,0),
		new OpcodeInfo(0x11,"cba",AddressMode.Inherent,0),
		new OpcodeInfo(0x12,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x13,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x14,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x15,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x16,"tab",AddressMode.Inherent,0),
		new OpcodeInfo(0x17,"tba",AddressMode.Inherent,0),
		new OpcodeInfo(0x18,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x19,"daa",AddressMode.Inherent,0),
		new OpcodeInfo(0x1a,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x1b,"aba",AddressMode.Inherent,0),
		new OpcodeInfo(0x1c,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x1d,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x1e,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x1f,"ill",AddressMode.Illegal,0),

		new OpcodeInfo(0x20,"bra",AddressMode.Relative,1),
		new OpcodeInfo(0x21,"brn",AddressMode.Relative,1),
		new OpcodeInfo(0x22,"bhi",AddressMode.Relative,1),
		new OpcodeInfo(0x23,"bls",AddressMode.Relative,1),
		new OpcodeInfo(0x24,"bcc",AddressMode.Relative,1),
		new OpcodeInfo(0x25,"bcs",AddressMode.Relative,1),
		new OpcodeInfo(0x26,"bne",AddressMode.Relative,1),
		new OpcodeInfo(0x27,"beq",AddressMode.Relative,1),
		new OpcodeInfo(0x28,"bvc",AddressMode.Relative,1),
		new OpcodeInfo(0x29,"bvs",AddressMode.Relative,1),
		new OpcodeInfo(0x2a,"bpl",AddressMode.Relative,1),
		new OpcodeInfo(0x2b,"bmi",AddressMode.Relative,1),
		new OpcodeInfo(0x2c,"bge",AddressMode.Relative,1),
		new OpcodeInfo(0x2d,"blt",AddressMode.Relative,1),
		new OpcodeInfo(0x2e,"bgt",AddressMode.Relative,1),
		new OpcodeInfo(0x2f,"ble",AddressMode.Relative,1),

		new OpcodeInfo(0x30,"tsx",AddressMode.Inherent,0),
		new OpcodeInfo(0x31,"ins",AddressMode.Inherent,0),
		new OpcodeInfo(0x32,"pula",AddressMode.Inherent,0),
		new OpcodeInfo(0x33,"pulb",AddressMode.Inherent,0),
		new OpcodeInfo(0x34,"des",AddressMode.Inherent,0),
		new OpcodeInfo(0x35,"txs",AddressMode.Inherent,0),
		new OpcodeInfo(0x36,"psha",AddressMode.Inherent,0),
		new OpcodeInfo(0x37,"pshb",AddressMode.Inherent,0),
		new OpcodeInfo(0x38,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x39,"rts",AddressMode.Inherent,0),
		new OpcodeInfo(0x3a,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x3b,"rti",AddressMode.Inherent,0),
		new OpcodeInfo(0x3c,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x3d,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x3e,"sync",AddressMode.Inherent,0),
		new OpcodeInfo(0x3f,"swi",AddressMode.Inherent,0),

		new OpcodeInfo(0x40,"nega",AddressMode.Inherent,0),
		new OpcodeInfo(0x41,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x42,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x43,"coma",AddressMode.Inherent,0),
		new OpcodeInfo(0x44,"lsra",AddressMode.Inherent,0),
		new OpcodeInfo(0x45,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x46,"rora",AddressMode.Inherent,0),
		new OpcodeInfo(0x47,"asra",AddressMode.Inherent,0),
		new OpcodeInfo(0x48,"asla",AddressMode.Inherent,0),
		new OpcodeInfo(0x49,"rola",AddressMode.Inherent,0),
		new OpcodeInfo(0x4a,"deca",AddressMode.Inherent,0),
		new OpcodeInfo(0x4b,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x4c,"inca",AddressMode.Inherent,0),
		new OpcodeInfo(0x4d,"tsta",AddressMode.Inherent,0),
		new OpcodeInfo(0x4e,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x4f,"clra",AddressMode.Inherent,0),

		new OpcodeInfo(0x50,"negb",AddressMode.Inherent,0),
		new OpcodeInfo(0x51,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x52,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x53,"comb",AddressMode.Inherent,0),
		new OpcodeInfo(0x54,"lsrb",AddressMode.Inherent,0),
		new OpcodeInfo(0x55,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x56,"rorb",AddressMode.Inherent,0),
		new OpcodeInfo(0x57,"asrb",AddressMode.Inherent,0),
		new OpcodeInfo(0x58,"aslb",AddressMode.Inherent,0),
		new OpcodeInfo(0x59,"rolb",AddressMode.Inherent,0),
		new OpcodeInfo(0x5a,"decb",AddressMode.Inherent,0),
		new OpcodeInfo(0x5b,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x5c,"incb",AddressMode.Inherent,0),
		new OpcodeInfo(0x5d,"tstb",AddressMode.Inherent,0),
		new OpcodeInfo(0x5e,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x5f,"clrb",AddressMode.Inherent,0),

		new OpcodeInfo(0x60,"neg",AddressMode.Indexed,1),
		new OpcodeInfo(0x61,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x62,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x63,"com",AddressMode.Indexed,1),
		new OpcodeInfo(0x64,"lsr",AddressMode.Indexed,1),
		new OpcodeInfo(0x65,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x66,"ror",AddressMode.Indexed,1),
		new OpcodeInfo(0x67,"asr",AddressMode.Indexed,1),
		new OpcodeInfo(0x68,"asl",AddressMode.Indexed,1),
		new OpcodeInfo(0x69,"rol",AddressMode.Indexed,1),
		new OpcodeInfo(0x6a,"dec",AddressMode.Indexed,1),
		new OpcodeInfo(0x6b,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x6c,"inc",AddressMode.Indexed,1),
		new OpcodeInfo(0x6d,"tst",AddressMode.Indexed,1),
		new OpcodeInfo(0x6e,"jmp",AddressMode.Indexed,0),
		new OpcodeInfo(0x6f,"clr",AddressMode.Indexed,1),

		new OpcodeInfo(0x70,"neg",AddressMode.Extended,2),
		new OpcodeInfo(0x71,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x72,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x73,"com",AddressMode.Extended,2),
		new OpcodeInfo(0x74,"lsr",AddressMode.Extended,2),
		new OpcodeInfo(0x75,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x76,"ror",AddressMode.Extended,2),
		new OpcodeInfo(0x77,"asr",AddressMode.Extended,2),
		new OpcodeInfo(0x78,"asl",AddressMode.Extended,2),
		new OpcodeInfo(0x79,"rol",AddressMode.Extended,2),
		new OpcodeInfo(0x7a,"dec",AddressMode.Extended,2),
		new OpcodeInfo(0x7b,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x7c,"inc",AddressMode.Extended,2),
		new OpcodeInfo(0x7d,"tst",AddressMode.Extended,2),
		new OpcodeInfo(0x7e,"jmp",AddressMode.Extended,2),
		new OpcodeInfo(0x7f,"clr",AddressMode.Extended,2),

		new OpcodeInfo(0x80,"suba",AddressMode.Immediate,1),
		new OpcodeInfo(0x01,"cmpa",AddressMode.Immediate,1),
		new OpcodeInfo(0x82,"sbca",AddressMode.Immediate,1),
		new OpcodeInfo(0x83,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x84,"anda",AddressMode.Immediate,1),
		new OpcodeInfo(0x85,"bita",AddressMode.Immediate,1),
		new OpcodeInfo(0x86,"ldaa",AddressMode.Immediate,1),
		new OpcodeInfo(0x87,"staa",AddressMode.Immediate,1),
		new OpcodeInfo(0x88,"eora",AddressMode.Immediate,1),
		new OpcodeInfo(0x89,"adca",AddressMode.Immediate,1),
		new OpcodeInfo(0x8a,"oraa",AddressMode.Immediate,1),
		new OpcodeInfo(0x8b,"adda",AddressMode.Immediate,1),
		new OpcodeInfo(0x8c,"cpx",AddressMode.Immediate,2),
		new OpcodeInfo(0x8d,"bsr",AddressMode.Relative,0),
		new OpcodeInfo(0x8e,"lds",AddressMode.Immediate,2),
		new OpcodeInfo(0x8f,"sts",AddressMode.Immediate,2),

		new OpcodeInfo(0x90,"suba",AddressMode.Direct,1),
		new OpcodeInfo(0x91,"cmpa",AddressMode.Direct,1),
		new OpcodeInfo(0x92,"sbca",AddressMode.Direct,1),
		new OpcodeInfo(0x93,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0x94,"anda",AddressMode.Direct,1),
		new OpcodeInfo(0x95,"bita",AddressMode.Direct,1),
		new OpcodeInfo(0x96,"ldaa",AddressMode.Direct,1),
		new OpcodeInfo(0x97,"staa",AddressMode.Direct,1),
		new OpcodeInfo(0x98,"eora",AddressMode.Direct,1),
		new OpcodeInfo(0x99,"adca",AddressMode.Direct,1),
		new OpcodeInfo(0x9a,"oraa",AddressMode.Direct,1),
		new OpcodeInfo(0x9b,"adda",AddressMode.Direct,1),
		new OpcodeInfo(0x9c,"cpx",AddressMode.Direct,2),
		new OpcodeInfo(0x9d,"jsr",AddressMode.Direct,0),
		new OpcodeInfo(0x9e,"lds",AddressMode.Direct,2),
		new OpcodeInfo(0x9f,"sts",AddressMode.Direct,2),

		new OpcodeInfo(0xa0,"suba",AddressMode.Indexed,1),
		new OpcodeInfo(0xa1,"cmpa",AddressMode.Indexed,1),
		new OpcodeInfo(0xa2,"sbca",AddressMode.Indexed,1),
		new OpcodeInfo(0xa3,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xa4,"anda",AddressMode.Indexed,1),
		new OpcodeInfo(0xa5,"bita",AddressMode.Indexed,1),
		new OpcodeInfo(0xa6,"ldaa",AddressMode.Indexed,1),
		new OpcodeInfo(0xa7,"staa",AddressMode.Indexed,1),
		new OpcodeInfo(0xa8,"eora",AddressMode.Indexed,1),
		new OpcodeInfo(0xa9,"adca",AddressMode.Indexed,1),
		new OpcodeInfo(0xaa,"oraa",AddressMode.Indexed,1),
		new OpcodeInfo(0xab,"adda",AddressMode.Indexed,1),
		new OpcodeInfo(0xac,"cpx",AddressMode.Indexed,2),
		new OpcodeInfo(0xad,"jsr",AddressMode.Indexed,0),
		new OpcodeInfo(0xae,"lds",AddressMode.Indexed,2),
		new OpcodeInfo(0xaf,"sts",AddressMode.Indexed,2),

		new OpcodeInfo(0xb0,"suba",AddressMode.Extended,2),
		new OpcodeInfo(0xb1,"cmpa",AddressMode.Extended,2),
		new OpcodeInfo(0xb2,"sbca",AddressMode.Extended,2),
		new OpcodeInfo(0xb3,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xb4,"anda",AddressMode.Extended,2),
		new OpcodeInfo(0xb5,"bita",AddressMode.Extended,2),
		new OpcodeInfo(0xb6,"ldaa",AddressMode.Extended,2),
		new OpcodeInfo(0xb7,"staa",AddressMode.Extended,2),
		new OpcodeInfo(0xb8,"eora",AddressMode.Extended,2),
		new OpcodeInfo(0xb9,"adca",AddressMode.Extended,2),
		new OpcodeInfo(0xba,"oraa",AddressMode.Extended,2),
		new OpcodeInfo(0xbb,"adda",AddressMode.Extended,2),
		new OpcodeInfo(0xbc,"cpx",AddressMode.Extended,2),
		new OpcodeInfo(0xbd,"jsr",AddressMode.Extended,2),
		new OpcodeInfo(0xbe,"lds",AddressMode.Extended,2),
		new OpcodeInfo(0xbf,"sts",AddressMode.Extended,2),

		new OpcodeInfo(0xc0,"subb",AddressMode.Immediate,1),
		new OpcodeInfo(0xc1,"cmpb",AddressMode.Immediate,1),
		new OpcodeInfo(0xc2,"sbcb",AddressMode.Immediate,1),
		new OpcodeInfo(0xc3,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xc4,"andb",AddressMode.Immediate,1),
		new OpcodeInfo(0xc5,"bitb",AddressMode.Immediate,1),
		new OpcodeInfo(0xc6,"ldab",AddressMode.Immediate,1),
		new OpcodeInfo(0xc7,"stab",AddressMode.Immediate,1),
		new OpcodeInfo(0xc8,"eorb",AddressMode.Immediate,1),
		new OpcodeInfo(0xc9,"adcb",AddressMode.Immediate,1),
		new OpcodeInfo(0xca,"orab",AddressMode.Immediate,1),
		new OpcodeInfo(0xcb,"addb",AddressMode.Immediate,1),
		new OpcodeInfo(0xcc,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xcd,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xce,"ldx",AddressMode.Immediate,2),
		new OpcodeInfo(0xcf,"stx",AddressMode.Immediate,2),

		new OpcodeInfo(0xd0,"subb",AddressMode.Direct,1),
		new OpcodeInfo(0xd1,"cmpb",AddressMode.Direct,1),
		new OpcodeInfo(0xd2,"sbcb",AddressMode.Direct,1),
		new OpcodeInfo(0xd3,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xd4,"andb",AddressMode.Direct,1),
		new OpcodeInfo(0xd5,"bitb",AddressMode.Direct,1),
		new OpcodeInfo(0xd6,"ldab",AddressMode.Direct,1),
		new OpcodeInfo(0xd7,"stab",AddressMode.Direct,1),
		new OpcodeInfo(0xd8,"eorb",AddressMode.Direct,1),
		new OpcodeInfo(0xd9,"adcb",AddressMode.Direct,1),
		new OpcodeInfo(0xda,"orab",AddressMode.Direct,1),
		new OpcodeInfo(0xdb,"addb",AddressMode.Direct,1),
		new OpcodeInfo(0xdc,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xdd,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xde,"ldx",AddressMode.Direct,2),
		new OpcodeInfo(0xdf,"stx",AddressMode.Direct,2),

		new OpcodeInfo(0xe0,"subb",AddressMode.Indexed,1),
		new OpcodeInfo(0xe1,"cmpb",AddressMode.Indexed,1),
		new OpcodeInfo(0xe2,"sbcb",AddressMode.Indexed,1),
		new OpcodeInfo(0xe3,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xe4,"andb",AddressMode.Indexed,1),
		new OpcodeInfo(0xe5,"bitb",AddressMode.Indexed,1),
		new OpcodeInfo(0xe6,"ldab",AddressMode.Indexed,1),
		new OpcodeInfo(0xe7,"stab",AddressMode.Indexed,1),
		new OpcodeInfo(0xe8,"eorb",AddressMode.Indexed,1),
		new OpcodeInfo(0xe9,"adcb",AddressMode.Indexed,1),
		new OpcodeInfo(0xea,"orab",AddressMode.Indexed,1),
		new OpcodeInfo(0xeb,"addb",AddressMode.Indexed,1),
		new OpcodeInfo(0xec,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xed,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xee,"ldx",AddressMode.Indexed,2),
		new OpcodeInfo(0xef,"stx",AddressMode.Indexed,2),

		new OpcodeInfo(0xf0,"subb",AddressMode.Extended,2),
		new OpcodeInfo(0xf1,"cmpb",AddressMode.Extended,2),
		new OpcodeInfo(0xf2,"sbcb",AddressMode.Extended,2),
		new OpcodeInfo(0xf3,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xf4,"andb",AddressMode.Extended,2),
		new OpcodeInfo(0xf5,"bitb",AddressMode.Extended,2),
		new OpcodeInfo(0xf6,"ldab",AddressMode.Extended,2),
		new OpcodeInfo(0xf7,"stab",AddressMode.Extended,2),
		new OpcodeInfo(0xf8,"eorb",AddressMode.Extended,2),
		new OpcodeInfo(0xf9,"adcb",AddressMode.Extended,2),
		new OpcodeInfo(0xfa,"orab",AddressMode.Extended,2),
		new OpcodeInfo(0xfb,"addb",AddressMode.Extended,2),
		new OpcodeInfo(0xfc,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xfd,"ill",AddressMode.Illegal,0),
		new OpcodeInfo(0xfe,"ldx",AddressMode.Extended,2),
		new OpcodeInfo(0xff,"stx",AddressMode.Extended,2)
		};

		string[] Macros = {
		"PC100_",	
		"NOP_",
		"MRTS_",
		"KILL_",
		"CPUX_",
		"SPEC_",
		"EB_",
		"ILLEGAL_MACRO_",
		"ILLEGAL_MACRO_",
		"ILLEGAL_MACRO_",
		"ILLEGAL_MACRO_",
		"ILLEGAL_MACRO_",
		"ILLEGAL_MACRO_",
		"ILLEGAL_MACRO_",
		"ILLEGAL_MACRO_",
		"ILLEGAL_MACRO_",
		"BITON_",
		"BITOFF_",
		"BITINV_",
		"BITFL_",
		"BITONP_",
		"BITOFFP_",
		"BITINVP_",
		"BITFLP_",
		"BE18_",
		"BE19_",
		"BE1A_",
		"BE1B_",
		"BE1C_",
		"BE1D_",
		"BE1E_",
		"BE1F_",
		"BITON2_",
		"BITOFF2_",
		"BITINV2_",
		"ILLEGAL_MACRO_",
		"BITONP2_",
		"BITOFFP2_",
		"BITINVP2_",
		"ILLEGAL_MACRO_",
		"BE28_",
		"BE29_",
		"BE2A_",
		"BE2B_",
		"BE2C_",
		"BE2D_",
		"BE2E_",
		"BE2F_",
		"SOL_",
		"SOL_",
		"SOL_",
		"SOL_",
		"SOL_",
		"SOL_",
		"SOL_",
		"SOL_",
		"SOL_",
		"SOL_",
		"SOL_",
		"SOL_",
		"SOL_",
		"SOL_",
		"SOL_",
		"SOL_",
		"PTSSND_",
		"PTSQUE_",
		"POINTS_",
		"PTSDIG_",
		"EXE_",
		"EXE_",
		"EXE_",
		"EXE_",
		"EXE_",
		"EXE_",
		"EXE_",
		"EXE_",
		"EXE_",
		"EXE_",
		"EXE_",
		"EXE_",
		"RAMADD_",
		"RAMCPY_",
		"PRI_",
		"SLEEP_",
		"REMTHREAD_",
		"REMTHREADS_",
		"JSR_",
		"JSRD_",
		"BEQA_",
		"BNEA_",
		"BEQR_",
		"BNER_",
		"JMPD_",
		"SWSET_",
		"SWCLR_",
		"JMP_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEPI_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"SLEEP_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JMPR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"JSRDR_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"ADDRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"SETRAM_",
		"RSND_",
		"RSND_",
		"RSND_",
		"RSND_",
		"RSND_",
		"RSND_",
		"RSND_",
		"RSND_",
		"RSND_",
		"RSND_",
		"RSND_",
		"RSND_",
		"RSND_",
		"RSND_",
		"RSND_",
		"RSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_",
		"SSND_"
		};
		//---------------------------------------------------------------------------
		// constructor

		private const int _TABSPACING = 6;
		private const int _TAB1 = (_TABSPACING*3);
        private const int _TAB2 = (_TABSPACING*4);
		private const int _TAB3 = (_TABSPACING*5);
		private const int _TAB4 = (_TABSPACING*6);
		private const int _TAB5 = (_TABSPACING*7);
		private const int _TAB6 = (_TABSPACING*8);
		private const int _TAB7 = (_TABSPACING*10);

		private const byte _SYSROM = 0xFF;
		private const byte _FILL = 0x90;
		private const byte _SYSDATA = 0x80;
		private const byte _SWITCHTABLE = 0x70;
		private const byte _SOUNDTABLE = 0x60;
		private const byte _LAMPTABLE = 0x50;
		private const byte _TABLE = 0x40;
		private const byte _DATA = 0x30;
		private const byte _MACRO = 0x20;
		private const byte _CODE = 0x10;
		private const byte _UNKNOWN = 0x00;

		private ArrayList m_entries = null;
		private ArrayList m_labelList = null;
		private ArrayList m_outList = null;
		private ArrayList m_lampGroups = null;
		private ArrayList m_errorList = null;
		private ByteStruct[] m_DS;
		private GameData m_gameData;

		private ushort m_size;
		private ushort m_base;
		//private string m_ROMD800;
		//private string m_ROME000;

		// Our Entry Label Counters
		private	int m_branchEntryCount;
		private int m_subroutineEntryCount;
		//private int m_jumpEntryCount;
		private int m_soundStringCount;

		private ushort m_xReg;
		private string m_lastError;
		private string m_baseDirectory = "";

		public DASM()
		{
			m_outList = new ArrayList();
			m_size = 0x1000;
			m_base = 0xD800;

			m_DS = new ByteStruct[m_size];

			for ( int i=0;i<m_size;i++)
				m_DS[i].Flag = _UNKNOWN;

			// Reset the Entry Label Counters
			m_branchEntryCount=1;
			m_subroutineEntryCount=1;
			//m_jumpEntryCount=1;

			m_labelList = new ArrayList();

			//TODO: There may be issues with the lablelist because it does not
			//support disallowing duplicates by default.
			//m_labelList. .Duplicates = dupIgnore;
			//m_labelList.Sorted = true;

			m_lampGroups = new ArrayList();
			m_entries = new ArrayList();
			m_errorList = new ArrayList();
			m_gameData = new GameData();

			InitializeLabels();
		}

		//------------------------------------------------------------------------
		public string GetLastError {
			get {return m_lastError;}
		}
		//------------------------------------------------------------------------
		public bool Execute(string strm_gameData) {

			m_baseDirectory = Path.GetDirectoryName(strm_gameData);
			//TODO: Define callback for messages
			Console.WriteLine("Loading Configuration File...\n");
			if (m_gameData.LoadFromIni(strm_gameData)) {
				Console.WriteLine("Tracing and Identifying Code/Data...\n");
				if (ParseConfigurationFile()) {
					Console.WriteLine("Disassembling ROM Images...");
					if (DASMRange(0xd800,0xe800)) {
						return true;
					}
				}
			}
			else {
				m_lastError = m_gameData.GetLastError();
			}
			return false;
		}
		//-------------------------------------------------------------------------
		public bool SaveOutput(string outputFile) {
			try
			{
				if (m_errorList.Count > 0)
				{
					m_outList.Insert(4, ";--------------------------------------------------");
					for (int i = 0; i < m_errorList.Count; i++)
					{
						m_outList.Insert(4, ";    " + m_errorList[i]);
					}
					m_outList.Insert(4, "; Errors/Warnings Generated:");
				}
				using (StreamWriter sw = new StreamWriter(outputFile, false))
				{
					foreach (string item in m_outList)
					{
						sw.WriteLine(item);
					}
					sw.Flush();
					sw.Close();
				}
				return true;
			}
			catch {
				m_lastError = "Could not create output file: " + outputFile;
				return false;
			}
		}
		//-------------------------------------------------------------------------
		private bool ParseConfigurationFile() {

			string tempstring;
			int i,j,temp,curraddress;
			ushort pc = m_base;

			ArrayList templist = new ArrayList();

			for (i=0;i<m_gameData.LabelList.Count;i++) {
				m_labelList.Add(m_gameData.LabelList[i]);
			}

			if (File.Exists(m_gameData.ROMLow)) {
				if( !LoadROM( m_gameData.ROMLow, 0xd800, 0x800))
				{
					m_lastError = "'ROMLow' File Open Error: " + m_gameData.ROMLow;
					return false;
				}
			}
			else {
				m_lastError = "'ROMLow' does not exists: " + m_gameData.ROMLow;
				return false;
			}

			if (File.Exists(m_gameData.ROMHigh)) {
				if( !LoadROM(m_gameData.ROMHigh, 0xE000, 0x800))
				{
					m_lastError = "'ROMHigh' File Open Error: " + m_gameData.ROMHigh;
					return false;
				}
			}
			else {
				m_lastError = "'ROMHigh' does not exists: " + m_gameData.ROMHigh;
				return false;
			}

			// Data from D800-E7FF now resides in ByteList
			// Get ready for first pass DASM which will....
			//   	Start at the system hooks and set the flags for each byte
			//      that it runs over. It will also associate labels into the
			//      m_labelList for the 2nd pass. We know that the following
			//      system pointers are code entry points
			//
			// Process the hook entries..
			ProcessEvent(0xE09f,"switch_event");
			ProcessEvent(0xE0A1,"sound_event");
			ProcessEvent(0xE0A3,"score_event");
			ProcessEvent(0xE0A5,"eb_event");
			ProcessEvent(0xE0A7,"special_event");
			ProcessEvent(0xE0A9,"macro_event");
			ProcessEvent(0xE0AB,"ballstart_event");
			ProcessEvent(0xE0AD,"addplayer_event");
			ProcessEvent(0xE0AF,"gameover_event");
			ProcessEvent(0xE0B1,"hstdtoggle_event");

			// Now we will add in the *required* system pointers to m_entries
			AddEntry(GetWord(0xe067), _CODE);
			AddLabel(GetstringWord(0xe067)+" gameover_entry");
			AddEntry(GetWord(0xe0b3), _CODE);
			AddLabel(GetstringWord(0xe0b3)+" hook_reset");
			AddEntry(GetWord(0xe0b5), _CODE);
			AddLabel(GetstringWord(0xe0b5)+" hook_mainloop");
			AddEntry(GetWord(0xe0b7), _CODE);
			AddLabel(GetstringWord(0xe0b7)+" hook_coin");
			AddEntry(GetWord(0xe0b9), _CODE);
			AddLabel(GetstringWord(0xe0b9)+" hook_gamestart");
			AddEntry(GetWord(0xe0bb), _CODE);
			AddLabel(GetstringWord(0xe0bb)+" hook_playerinit");
			AddEntry(GetWord(0xe0bd), _CODE);
			AddLabel(GetstringWord(0xe0bd)+" hook_outhole");

			AddEntry(0xE0BF, _CODE);
			AddEntry(0xE0C2, _CODE);
			// Mark all the 'known' system data stuff as _SYSDATA
			// It is always from 0xe000-0xe0be
			for (i=0xE000;i<=0xE0BE;i++){
				SetFlag(i,_SYSDATA);
			}
			// Lets do the switch table now
			int SwitchTableStart = GetWord(0xe051);
			for ( i=0; i<GetByte(0xe04d); i++) {  //do from 0 to last switch
				j = i*3;
				for ( int k=0; k<3;k++) {
					SetFlag(SwitchTableStart+j+k,_SWITCHTABLE);
				}
				temp = GetWord(SwitchTableStart+j+1);
				// we need to see if the switch entry is a macro or a cpu code based on bit 0x80
				if ((GetByte(SwitchTableStart+j) & (byte)0x80) > 0)
					AddEntry(temp, _MACRO); //Macro
				else
					AddEntry(temp, _CODE ); //Code
				// now add the switch label to the m_labelList
				if (i < 8 ) { //system common switches
					if (temp < 0xe800) {
						switch (i){
						case 0: AddLabel(temp.ToString("x4") + " sw_plumbtilt");
								break;
						case 1: AddLabel(temp.ToString("x4") + " sw_balltilt");
								break;
						case 2: AddLabel(temp.ToString("x4") + " sw_credit_button");
								break;
						case 3: AddLabel(temp.ToString("x4") + " sw_coin_r");
								break;
						case 4: AddLabel(temp.ToString("x4") + " sw_coin_c");
								break;
						case 5: AddLabel(temp.ToString("x4") + " sw_coin_l");
								break;
						case 6: AddLabel(temp.ToString("x4") + " sw_slam");
								break;
						case 7: AddLabel(temp.ToString("x4") + " sw_hstd_res");
								break;
						}
					}
				}
				else {
					if (((string)m_gameData.SwitchList[i]) != "") {
						AddLabel(temp.ToString("x4") + " sw_"+m_gameData.SwitchList[i]);
					}
					else {
						AddLabel(temp.ToString("x4") + " sw_"+i.ToString("x2")+"_entry");
					}
				}
			}

			/* We need to do the disassembly in two passes. The first pass will scan each code
			/  routine and flag it as either CODE,MACRO, or DATA.          */
			while (m_entries.Count != 0) {
				tempstring=(string)m_entries[0];
				// set the pc to the entry that we are going to scan
				pc = Convert.ToUInt16(tempstring.Substring(0,4),16);
				byte format = byte.Parse(tempstring.Substring(5,tempstring.Length-5));
    			//byte format = Convert.ToByte(hex,16);

				/* Check the byte flag to see if it has been scanned already, if so, dont trace it */
				if ( GetFlag(pc) == _UNKNOWN ) 
				{
					Trace(pc, format) ;
				}
				// now delete the address we just processed
				m_entries.RemoveAt(0);
			}
			// Now lets do the Sound Table, 3 bytes per entry. Max length is 0x1F (not)I think but it is
			// about the same process as the Lamp Table, we don't know how long it could be.
			m_soundStringCount=1;
			int tablestart = GetWord(0xE053);
			for (i=0;i<0x2F*3;i+=3) {
				int address = tablestart+i;
				if (GetFlag(address) == _UNKNOWN) {
					SetFlag(address,_SOUNDTABLE);
					SetFlag(address+1,_SOUNDTABLE);
					SetFlag(address+2,_SOUNDTABLE);
					if (GetByte(address+2)== (byte)0xFF) {
						SoundScan(GetWord(address));
					}
				}
			}
			// mark the lamp table.... this can be up to 0x1F*2 bytes long but it
			// usually isn't. We don't have a definite way of knowing how long the
			// table is either, which sucks. So, we are going to do it last and also
			// apply a little logic to try and guess the end of it.
			tablestart = GetWord(0xE04F);
			for ( i=0; i<(0x1F*2); i+=2) {
				if (GetFlag(tablestart+i) == _UNKNOWN) {
					if ( GetByte(tablestart+i) > 0x4f ) break;
					if ( (GetByte(tablestart+i))<(GetByte(tablestart+i+1)) ) {
						SetFlag(tablestart+i,_LAMPTABLE);
						SetFlag(tablestart+i+1,_LAMPTABLE);
					}
				}
			}
			/* Now that everything is marked with the trace/tables, we will check each
			/  unprocessed byte to see if it is 'unused'( 00 filled). If the two bytes
			/  before or after the byte is also '00', then we will mark it as a fill. */
			for (i=0;i<m_size;i++) {
				curraddress = m_base+i;
				if ( i<=0x10 ) {
				//  if ( CheckFill(curraddress,_dForward)==0 ) SetFlag(curraddress,_FILL);
				}
				else if ( i>(m_size-0x10) ) {
					if ( MyCheckFill(curraddress,TraceDirection.Back) ) SetFlag(curraddress,_FILL);
				}
				else {
					if  (MyCheckFill(curraddress,TraceDirection.Forward)||MyCheckFill(curraddress,TraceDirection.Back))
							SetFlag(curraddress,_FILL);
				}
			}

			// lets log the byteflags array here
			templist.Clear();
			for (i=0;i < m_size;i++) {
				curraddress = m_base + i;
				tempstring = "0x"+curraddress.ToString("x4")+": "+((byte)GetByte(curraddress)).ToString("x2");
				byte p = GetFlag(curraddress);
				if (p == _UNKNOWN) tempstring +="  not processed";
				else if (p == _CODE) tempstring +="  _code";
				else if (p == _MACRO) tempstring +="  _macro";
				else if (p == _DATA) tempstring +="  _data";
				else if (p == _TABLE) tempstring +="  _table";
				else if (p == _LAMPTABLE) tempstring +="  _lamptable";
				else if (p == _SOUNDTABLE) tempstring +="  _soundtable";
				else if ((((byte)p)>=0x61)&&(((byte)p)<=0x6f))
					tempstring +=" _complexsound"+ ((byte)(((byte)p)&0x0f)).ToString();
				else if (p == _SWITCHTABLE) tempstring +="  _switchtable";
				else if (p == _SYSDATA) tempstring +="  _sysdata";
				else if (p == _FILL) tempstring +="  _fill";
				else tempstring += "  Unknown ID:"+p.ToString("2x");
				templist.Add(tempstring);
			}
			StreamWriter sw = new StreamWriter("byteflags.log",false);
			foreach (string item in templist) 
			{
				sw.WriteLine(item);
			}
			sw.Flush();
			sw.Close();

			return true;
		}
		//------------------------------------------------------------------------
		private bool DASMRange(int start, int end )
		{
			int k,m,c,SwitchTableStart;
			string tempstring = "";

			m_outList.Add(";--------------------------------------------------------------");
			m_outList.Add(";"+m_gameData.GameName+" Game ROM Disassembly");
			m_outList.Add(";Dumped by Pinbuilder ©2000-2001 Jess M. Askey");
			m_outList.Add(";--------------------------------------------------------------");
			m_outList.Add("");
			m_outList.Add("#include  \"level7.exp\"	;Level 7 system defines");
			m_outList.Add("#include  \"wvm7.asm\"	;Level 7 macro defines");
			m_outList.Add("#include  \"68logic.asm\"	;680X logic definitions");
			m_outList.Add("#include  \"7gen.asm\"	;Level 7 general defines");
			m_outList.Add("");
			m_outList.Add(";--------------------------------------------------------------");
			m_outList.Add("; GAME RAM Locations:");
			m_outList.Add(";");
			m_outList.Add("; $02 - ");
			m_outList.Add("; $03 - ");
			m_outList.Add("; $04 - ");
			m_outList.Add("; $05 - ");
			m_outList.Add("; $06 - ");
			m_outList.Add("; $07 - ");
			m_outList.Add("; $08 - ");
			m_outList.Add("; $09 - ");
			m_outList.Add("; $0a - ");
			m_outList.Add("; $0b - ");
			m_outList.Add("; $0c - ");
			m_outList.Add("; $0d - ");
			m_outList.Add("; $0e - ");
			m_outList.Add("; $0f - ");
			m_outList.Add(";--------------------------------------------------");
			m_outList.Add("; Extra RAM Locations Used:");
			m_outList.Add(";");
			m_outList.Add(";");
			m_outList.Add(";");
			m_outList.Add(";");
			m_outList.Add(";");
			m_outList.Add(";--------------------------------------------------");
			m_outList.Add("; Game Bit Definitions:");
			m_outList.Add("; 1.1(00) - ");
			m_outList.Add("; 1.2(01) - ");
			m_outList.Add("; 1.3(02) - ");
			m_outList.Add("; 1.4(03) - ");
			m_outList.Add("; 1.5(04) - ");
			m_outList.Add("; 1.6(05) - ");
			m_outList.Add("; 1.7(06) - ");
			m_outList.Add("; 1.8(07) - ");
			m_outList.Add("; 2.1(08) - ");
			m_outList.Add("; 2.2(09) - ");
			m_outList.Add("; 2.3(0A) - ");
			m_outList.Add("; 2.4(0B) - ");
			m_outList.Add("; 2.5(0C) - ");
			m_outList.Add("; 2.6(0D) - ");
			m_outList.Add("; 2.7(0E) - ");
			m_outList.Add("; 2.8(0F) - ");
			m_outList.Add("; 3.1(10) - ");
			m_outList.Add("; 3.2(11) - ");
			m_outList.Add("; 3.3(12) - ");
			m_outList.Add("; 3.4(13) - ");
			m_outList.Add("; 3.5(14) - ");
			m_outList.Add("; 3.6(15) - ");
			m_outList.Add("; 3.7(16) - ");
			m_outList.Add("; 3.8(17) - ");
			m_outList.Add("; 4.1(18) - ");
			m_outList.Add("; 4.2(19) - ");
			m_outList.Add("; 4.3(1A) - ");
			m_outList.Add("; 4.4(1B) - ");
			m_outList.Add("; 4.5(1C) - ");
			m_outList.Add("; 4.6(1D) - ");
			m_outList.Add("; 4.7(1E) - ");
			m_outList.Add("; 4.8(1F) - ");
			m_outList.Add("; 5.1(20) - ");
			m_outList.Add("; 5.2(21) - ");
			m_outList.Add("; 5.3(22) - ");
			m_outList.Add("; 5.4(23) - ");
			m_outList.Add("; 5.5(24) - ");
			m_outList.Add("; 5.6(25) - ");
			m_outList.Add("; 5.7(26) - ");
			m_outList.Add("; 5.8(27) - ");
			m_outList.Add("; 6.1(28) - ");
			m_outList.Add("; 6.2(29) - ");
			m_outList.Add("; 6.3(2A) - ");
			m_outList.Add("; 6.4(2B) - ");
			m_outList.Add("; 6.5(2C) - ");
			m_outList.Add("; 6.6(2D) - ");
			m_outList.Add("; 6.7(2E) - ");
			m_outList.Add("; 6.8(2F) - ");
			m_outList.Add("; 7.1(30) - ");
			m_outList.Add("; 7.2(31) - ");
			m_outList.Add("; 7.3(32) - ");
			m_outList.Add("; 7.4(33) - ");
			m_outList.Add("; 7.5(34) - ");
			m_outList.Add("; 7.6(35) - ");
			m_outList.Add("; 7.7(36) - ");
			m_outList.Add("; 7.8(37) - ");
			m_outList.Add("; 8.1(38) - ");
			m_outList.Add("; 8.2(39) - ");
			m_outList.Add("; 8.3(3A) - ");
			m_outList.Add("; 8.4(3B) - ");
			m_outList.Add("; 8.5(3C) - ");
			m_outList.Add("; 8.6(3D) - ");
			m_outList.Add("; 8.7(3E) - ");
			m_outList.Add("; 8.8(3F) - ");
			m_outList.Add(";--------------------------------------------------");
			m_outList.Add(";;* Define Our Solenoids and the time they should be on for each trigger.");
			m_outList.Add("");
			for (int s=0 ; s<32; s++) 
			{
				string timer = (string)m_gameData.SolenoidTimers[s];
				if (timer != "")  
				{
					string solstring = (string)m_gameData.SolenoidList[s] + "_on";
					Tab(ref solstring, _TAB3);
					solstring += "$"+ IntToHex(s,2) + "+" + GetSolenoidTimer((string)m_gameData.SolenoidTimers[s]);
					m_outList.Add(solstring);
					solstring = (string)m_gameData.SolenoidList[s] + "_off";
					Tab(ref solstring, _TAB3);
					solstring += "$"+ IntToHex(s,2)+ "+SOLENOID_OFF";
					m_outList.Add(solstring);
				}
			}
			m_outList.Add("");
			m_outList.Add("");

			string linedata;
			m_outList.Add("	.org $d800");
			m_outList.Add("");

			for (int i=0;i<m_size;i++) {
				linedata ="";
				int curraddress = m_base+i;
			// Begin Breakpoint Code -----------------------------------
										if ( curraddress == 0xd805 ) {
											k = 0;
										}
			// End Breakpoint Code -------------------------------------
				byte flag = GetFlag(curraddress);
				if ((curraddress>=0xe000)&&(curraddress<=0xE0be)) {
					DumpSystemData();
					i=0xE0be-m_base;
				}
				else {
					linedata = GetAllLabels(curraddress);
					Tab(ref linedata,_TAB1);
					byte xx = (byte)(flag & 0xf0);
					switch ((byte)(flag & 0xf0)) {
						case _CODE:
							i += DASM680x (curraddress, ref linedata);
							m_outList.Add(linedata);
							i--;
							break;
						case _MACRO:
							i += DASMmacro(curraddress, ref linedata);
							break;
						case _UNKNOWN:
							i += SpewData(curraddress,flag,16,"");
							m_outList.Add("");
							break;
						case _DATA:
							i += SpewData(curraddress,flag,16,"");
							m_outList.Add("");
							break;
						case _FILL:
							i += SpewData(curraddress,flag,16,"");
							m_outList.Add("");
							break;
						case _TABLE:
							i += SpewData(curraddress,flag,2,"");
							break;
						case _LAMPTABLE:
							m_outList.Add("");
							k=0;
							m=0;
							while ( GetFlag(curraddress+k) == _LAMPTABLE ) {
								if ( k == 0 )
									linedata = "lamptable\t\t.db $";
								else
									linedata = "\t\t\t.db $";
								linedata += GetstringByte(curraddress+k)+" ,$"+GetstringByte(curraddress+k+1);
								linedata += "\t;("+m.ToString("x2")+") ";
								tempstring = m_gameData.LampList[(GetByte(curraddress+k)& 0x3f)]+" -- ";
								tempstring += m_gameData.LampList[(GetByte(curraddress+k+1)& 0x3f)];
								linedata += tempstring;
								m_outList.Add(linedata);
								m_lampGroups.Add(tempstring);
								m++;
								k+=2;
							}
							i += k-1;
							m_outList.Add("");
							break;
						case _SOUNDTABLE:
							if ((((byte)flag)&0x0f)==0) { //main table
								m_outList.Add("");
								k=0;
								m=0;
								c=1;
								while ( GetFlag(curraddress+k) == _SOUNDTABLE ) {
									if ( k == 0 )
										linedata = "soundtable\t\t";
									else
										linedata = "\t\t\t";
									if ( GetByte(curraddress+k+2) == 0xFF ) { // complex sound
										linedata += ".dw c_sound"+c.ToString()+"\\\t.db $"+GetstringByte(curraddress+k+2);
										c++;
									}
									else {
										linedata += ".db $"+GetstringByte(curraddress+k)+", $"+GetstringByte(curraddress+k+1)+",\t$"+GetstringByte(curraddress+k+2)+"\t";
									}
									linedata += "\t;("+m.ToString("x2")+") ";
									m_outList.Add(linedata);
									m++;
									k+=3;
								}
								i += k-1;
							}
							else { // Extended Sound Data
								i += SpewData(curraddress,flag,16,"c_sound"+(((byte)flag)&0x0f).ToString());
							}
							m_outList.Add("");
							break;
						case _SWITCHTABLE:
							m_outList.Add("");
							k=0;
							m=0;
							SwitchTableStart = GetWord(0xe051);
							while ( GetFlag(curraddress+k) == _SWITCHTABLE ) {
								if ( k == 0 )
									linedata = "switchtable\t\t.db ";
								else
									linedata = "\t\t\t.db ";
								linedata += IntToBin(GetByte(curraddress+k))+"\t\\.dw ";
								if ( GetWord(curraddress+k+1) >= 0xe800 ) { //switch entry is in system ROM
									tempstring = GetSingleLabel(GetWord(curraddress+k+1));
									if (tempstring == null) {
										linedata += "$"+GetstringWord(curraddress+k+1)+"\t";
									}
									else {
										linedata += tempstring;
									}
								}
								else  { // in game ROM, get the label that was assigned to it.
									if (((string)m_gameData.SwitchList[(curraddress+k-SwitchTableStart)/3]) != "") {
										linedata += "sw_"+m_gameData.SwitchList[(curraddress+k-SwitchTableStart)/3];
									}
									else {
										linedata += "sw_"+(((int)(curraddress+k-SwitchTableStart)/3)).ToString("x2")+"_entry";
									}
								}
								Tab(ref linedata,_TAB7);
								linedata += ";("+((int)(m+1)).ToString()+") ";
								if ((string)m_gameData.SwitchNameList[m] != "") 
								{
									tempstring = (string)m_gameData.SwitchNameList[m];
								}
								else 
								{
									tempstring = "sw_"+m_gameData.SwitchList[m];
								}
								linedata += tempstring;
								m_outList.Add(linedata);
								m_lampGroups.Add(tempstring);
								m++;
								k+=3;
							}
							i += k-1;
							m_outList.Add("switchtable_end");
							m_outList.Add("");
							break;
						case _SYSDATA:
							i += SpewData(curraddress,flag,16,"");
							break;
						default:
							Console.WriteLine("Byte ID is Unknown");
							i=1;
							break;
					}
				}
			}
			m_outList.Add("");
			m_outList.Add("\t.end");
			m_outList.Add("");
			m_outList.Add(";**************************************");
			m_outList.Add(";* Label Definitions                   ");
			m_outList.Add(";**************************************");
			for (int i=0;i<m_labelList.Count;i++) {
				ushort localaddress = Convert.ToUInt16(((string)m_labelList[i]).Substring(0,4),16);
				if ( (0xD800<=localaddress)&&(localaddress<0xe000) ||
					(0xe0c2<localaddress)&&(localaddress<0xe800)) {
				m_outList.Add("; "+m_labelList[i]);
				}
			}
			return true;
		}
		//---------------------------------------------------------------------------
		private bool LoadROM ( string FileName, int rom_base, int size)
		{
			FileStream fs = new FileStream(FileName, FileMode.Open,FileAccess.Read);

			try {
				
				for (int i=0;i<size;i++)
					m_DS[rom_base-m_base+i].Data = (byte)fs.ReadByte();
				return true;
			}

			catch {
				Console.WriteLine("Cannot load "+FileName);
				return false;
			}
		}

		//------------------------------------------------------------------------
		// SetFlag() - Sets ID code for address
		private bool SetFlag( int address, byte type ) {

			if (address < 0x8000) address += 0x8000;

			if ( (address > (m_base+m_size)) || (address < m_base) ) {
				m_errorList.Add("Address out of Range: 0x"+address.ToString("x6"));
				return false;
			}
			else {
				m_DS[address-m_base].Flag = type;
				return true;
			}
		}
		//------------------------------------------------------------------------
		// GetFlag() - Gets ID code for address
		private byte GetFlag( int address) {

			if (address < 0x8000) address += 0x8000;

			if ( (address > 0xffff) || (address < m_base) )
			{
				m_errorList.Add("Address out of Range: 0x"+address.ToString("x6"));
				return 0;
			}
			else {
				if (address >=0xe800) return _SYSROM;
				return m_DS[address-m_base].Flag;
			}
		}
		//------------------------------------------------------------------------
		// GetByteStr() - Returns Next Byte N in an Ansistring
		//------------------------------------------------------------------------
		private string GetstringByte( int address)
		{
			if (address < 0x8000) address += 0x8000;

			if ( (address > 0xffff) || (address < m_base) )
			{
				m_errorList.Add("Address out of Range: 0x"+address.ToString("x6"));
				return "00";
			}
			else {
				string ReturnData = ((byte)(m_DS[address-m_base].Data)).ToString("x2");
				return ReturnData;
			}
		}
		//------------------------------------------------------------------------
		// GetWordStr() - Returns Next Word N in an Ansistring
		//------------------------------------------------------------------------
		private string GetstringWord( int address)
		{
			if (address < 0x8000) address += 0x8000;

			if ( (address > 0xffff) || (address < m_base) )
			{
				m_errorList.Add("Address out of Range: 0x"+address.ToString("x6"));
				return "XXXX";
			}
			else {
				string ReturnData = ((byte)(m_DS[address-m_base].Data)).ToString("x2");
				ReturnData += ((byte)(m_DS[address-m_base+1].Data)).ToString("x2");
				return ReturnData;
			}
		}
		//------------------------------------------------------------------------
		// GetByte() - Returns Next Byte N
		//------------------------------------------------------------------------
		private byte GetByte (int address)
		{
			if (address < 0x8000) address += 0x8000;

			if ( (address > 0xffff) || (address < m_base) )
			{
				m_errorList.Add("Address out of range: 0x"+address.ToString("x6"));
				return 0;
			}
			else
				return m_DS[address-m_base].Data;
		}
		//------------------------------------------------------------------------
		//  GetWord() - Returns Next Word
		//------------------------------------------------------------------------
		private ushort GetWord ( int address)
		{
			ushort high = 0;
			ushort low = 0;
			ushort word = 0;
			if (address < 0x8000) address += 0x8000;

			if ( (address > (m_base+m_size)) || (address < m_base) )
			{
				m_errorList.Add("Address out of range: 0x"+address.ToString("x6"));
				return 0;
			}
			else
				high = (ushort)((m_DS[address-m_base].Data)<<8);
				low = m_DS[address-m_base+1].Data;
				word = (ushort)(high+low);
				return word;
		}
		//------------------------------------------------------------------------
		private void GetDataBytes( int address, int bytes) {

			if (address < 0x8000) address += 0x8000;
		    
			if ( (address > 0xffff) || (address < m_base) )
			{
				m_errorList.Add("Address out of Range: 0x"+address.ToString("x6"));
			}
			else {
				string SingleData ="";
				for ( int j=0;j<bytes;j++) {
           			SingleData =".db "+m_DS[address+j-m_base].Data.ToString();
					m_outList.Add(SingleData);
				}
			}
		}
		//---------------------------------------------------------------------------
		private string GetSingleLabel(int address)
		{
			string label=null;
			string line=null;
			for (int i=0;i<m_labelList.Count;i++) {
				line = (string)m_labelList[i];
				string aline = line.Substring(0,4);
				int addr = Convert.ToUInt16(aline,16);
				if (addr == address) {
					line = line.Remove(0,5);
					label=line;
					break;
				}
			}
			return label;
		}
		//---------------------------------------------------------------------------
		private string GetAllLabels(int address)
		{
			ArrayList templist = new ArrayList();
			string label="";
			string line;
			int i;

			//--------------------------------------------
				if (address == 0xdcc1) {
					line = "test";
				}
			//---------------------------------------------

			for (i=0;i<m_labelList.Count;i++) {
				line = (string)m_labelList[i];
				if (Convert.ToUInt16(line.Substring(0,4),16) == address) {
					line = line.Remove(0,5);
					templist.Add(line);
				}
			}
			int last = templist.Count;
			if (last>0) {
				for (i=1;i<(last);i++)
					m_outList.Add(templist[i-1]);
				label = (string)templist[last-1];
			}

			return label;
		}
		//------------------------------------------------------------------------
		// Datastring():
		//------------------------------------------------------------------------
		private string Datastring( int pc, int bytes){
			string Datastring;
			Datastring = ".db";
			for (int i=0;i<bytes-1;i++) {
				Datastring += " $"+GetstringByte(pc+i)+",";
			}
			Datastring += " $"+GetByte(pc+bytes-1);
			return Datastring;
		}
		//------------------------------------------------------------------------
		// AddEntry()
		//------------------------------------------------------------------------
		private void AddEntry ( int newaddress, byte mode) {

			string newstring = IntToHex(newaddress,4);
			newstring = newstring.ToUpper();
			bool flag=true;
			if ( newaddress >= 0xE800 ) {
					flag = false;
			}
			if ( newaddress == 0xE119 ) {
				flag = true;
			}
			else {
				for (int i=0;i<m_entries.Count;i++) {
					if (((string)m_entries[i]).Substring(0,4) == newstring )
						flag = false;
				}
			}
			if (flag) m_entries.Add(newstring+" "+mode);
		}
		//------------------------------------------------------------------------------
		private void AddLabel(string Label)
		{
			m_labelList.Add(Label);
		}
		//------------------------------------------------------------------------
		private int SpewData( int pc , byte type ,int bytesperline, string label){
			int i=0,j=0;
			string linedata;
			while ( GetFlag(pc+j) == type ) {
				if (j==0) {
					linedata = label;
					Tab(ref linedata,_TAB1);
					linedata += ".db $";
				}
				else
					linedata = "\t\t\t.db $";
				for ( i=0;i<bytesperline;i++) {
					byte flag = GetFlag(pc+i+j);
					if ( (flag != type)||(pc+i+j>=0xe800)) {
						break;
					}
					linedata += GetstringByte(pc+i+j);
					if ( GetFlag(pc+j+i+1)== type)
					{
						if (i<(bytesperline-1) )
						{
								linedata += ",$";
						}
					}
				}
				j+=i;
				m_outList.Add(linedata);
			}
			return j-1;
		}
		//------------------------------------------------------------------------------
		private void Tab(ref string text, int indent)
		{
			//set up a working text string that we can mutilate
			string line = text;
			int pos = line.IndexOf("\t");
			//first we need to convert the tabs into spaces
			while (pos > -1) {
				int spaces = _TABSPACING -( (pos) % _TABSPACING);
				line = line.Remove(pos,1);   //delete the \t character
				string spacestring = "";
				for (int i=0;i<spaces;i++)
				{
					spacestring += " ";
				}
				line = line.Insert(pos,spacestring);
				pos = line.IndexOf("\t");
			}
			int length = line.Length;
			int difference = indent - length;
			int tabs = difference / _TABSPACING;
			if ( (difference % _TABSPACING) != 0 ) tabs++;
			if ( tabs < 0) tabs = 0;
			for (int i=0;i<tabs;i++) {
				//text = text.Insert(0,"\t");
				text += "\t";
			}
		}
		//------------------------------------------------------------------------------
		private string GoBranch( int pc, ref ushort i) {
			string branchstring="",logic="";
			int nextbyte = GetByte(pc+i);
			if ( nextbyte >= 0xF9 ) {
				if ( (nextbyte == 0xFC ) || (nextbyte == 0xFD ) ) {
					if ( nextbyte == 0xFC ) logic = "=="; // =?
					else if ( nextbyte == 0xFD ) logic = ">="; // A >= B
					i+=1;
					branchstring = GoBranch( pc, ref i)+logic;
					branchstring += "#";
					branchstring += GetByte( pc+i);
					i+=1;
				}
				else {
					if ( nextbyte == 0xF9 ) logic = " + ";  // A = A+ B
					else if ( nextbyte == 0xFA ) logic = " && ";  // AND
					else if ( nextbyte == 0xFB ) logic = " || ";  // OR
					else if ( nextbyte == 0xFE ) logic = " P ";  // Priority
					else if ( nextbyte == 0xFF ) logic = " & ";  // &&
					i+=1;
					branchstring ="(";
					branchstring += GoBranch( pc, ref i)+logic+GoBranch( pc, ref i);
					branchstring += ")";
					}
				}
			else if ( nextbyte <= 0xF1) { // self, no data
				if ( nextbyte <= 0x2F ) branchstring = "LAMP#"+GetstringByte(pc+i)+"("+m_gameData.LampList[GetByte(pc+i)]+")";
				else if (nextbyte <= 0xCF ) branchstring = "BIT#"+IntToHex(GetByte(pc+i)-0x40,2);
				else if (nextbyte <= 0xDF ) branchstring = "ADJ#"+IntToHex(0x0F&(GetByte(pc+i)),1);
				else if (nextbyte <= 0xEF ) branchstring = "RAM$"+IntToHex(0x0F&(GetByte(pc+i)),2);
				else if (nextbyte == 0xF0 ) branchstring = "TILT";
				else if (nextbyte == 0xF1 ) branchstring = "GAME";
				i+=1;
			}
			else if ( nextbyte == 0xF2) { // self, +1 data
				branchstring = "#";
				branchstring += IntToHex(GetByte(pc+i+1),2);
				i+=2;
			}
			else if ( nextbyte == 0xF3) {
				branchstring = "(!";
				i+=1;
				branchstring += GoBranch (pc, ref i);
				branchstring += ")";
			}
			else  { // lamp branch
				if ( nextbyte == 0xF4) branchstring = "LampOn/Flash#"+GetstringByte(pc+i+1);
				if ( nextbyte == 0xF5) branchstring = "RangeOFF#"+GetstringByte(pc+i+1);
				if ( nextbyte == 0xF6) branchstring = "RangeON#"+GetstringByte(pc+i+1);
				if ( nextbyte == 0xF7) branchstring = "BIT#"+GetstringByte(pc+i+1);
				if ( nextbyte == 0xF8) branchstring = "SW#"+GetstringByte(pc+i+1);
				i+=2;
			}
			return branchstring;
		}
		//------------------------------------------------------------------------------
		private string IntToHex(int value, int digits) 
		{
			string sdigits = "x" + digits.ToString();
			return value.ToString(sdigits);
		}
		
		private ushort MacroDataLength (int pc)
		{
			ushort i=1;
			while ( (GetByte(pc)&0x80) > 0) {
				pc++;
				i++;
			}
			return i;
		}
		//------------------------------------------------------------------------------
		private string Points (int data) {
			int points=0;
			int digit = data & 0x07;
			int increment = (data & 0x78)>>3;
			for (int j=0;j<increment;j++) {
				points += 10^digit;
			}
			return points.ToString();
		}
		//------------------------------------------------------------------------------
		private string IntToBin(int number)
		{
			string bin = Convert.ToString(number, 2);
			if (bin.Length < 8) 
			{
				bin = bin.Insert(0,new String('0',8-bin.Length));
			}
			return bin;
		}
		//------------------------------------------------------------------------------
		private string GetSolenoidTimer (string timerstring) 
		{
			int timer = int.Parse(timerstring)>>5;
			if (timer == 7) 
			{
				return "SOLENOID_ON_LATCH";
			}
			else 
			{
				return "SOLENOID_ON_"+ IntToHex(timer,1) +"_CYCLES";
			}
		}
		//------------------------------------------------------------------------------
		private string Mnemonic( int opcode) {
			return Opcodes[opcode].Name;
		}
		//------------------------------------------------------------------------------
		private AddressMode Addressmode ( int opcode) {
			return Opcodes[opcode].Mode;
		}
		//------------------------------------------------------------------------------
		private int Databytes ( int opcode ) {
			return Opcodes[opcode].Operands;
		}
		//------------------------------------------------------------------------------
		private bool MyCheckFill (int index, TraceDirection direction )
		{
			if (GetFlag(index) > _UNKNOWN ) return false;
			int i;
			if (direction == TraceDirection.Forward ) {
				for (i=index;i<index+0x10;i++) {
					if (GetByte(i)!=0)
						return false;
				}
			}
			else if (direction == TraceDirection.Back) {
				for (i=index-0x10;i<=index;i++) {
					if (GetByte(i)!=0)
						return false;
				}
			}
			return true;
		}
		//---------------------------------------------------------------------------
		private void ProcessEvent(int address, string label) {
				int offset = GetByte(address+1);
				if (GetByte(address) == 0x20) {
					AddLabel(IntToHex(address+2+offset,4)+" "+label);
					AddEntry(address+2+offset, _CODE);
				}
			}
		//---------------------------------------------------------------------------
		private bool CheckLabel(int address, ref string Label)
		{
			bool found = false;
			for (int i=0;i<m_labelList.Count;i++) {
				string line = (string)m_labelList[i];
				if (Convert.ToUInt16("0x"+line.Substring(0,4),16) == address) {
					line = line.Remove(0,5);
					Label += line;
					found = true;
					break;
				}
			}
			return found;
		}
		//---------------------------------------------------------------------------
		private int DASM680x ( int pc, ref string rettext)
		{
			//rettext already contains leading address info...
			int offset,address,bytes;
			int opcode = GetByte(pc);
			int databytes = Databytes(opcode);

			// Begin Breakpoint Code -----------------------------------
										if ( pc == 0xd800 ) {
											offset = 0;
										}
			// End Breakpoint Code -------------------------------------

			Tab(ref rettext,_TAB1);
			rettext += Mnemonic(opcode);
			rettext += "\t";
			switch( Addressmode(opcode) )
			{
				case AddressMode.Relative:  /* relative (branches)*/
					offset = GetByte(pc+1);
					address = pc+2+((offset<128) ? offset : offset-256);
								if (!CheckLabel(address,ref rettext))
								{
										m_errorList.Add("Unlabeled rel address at "+IntToHex(pc,4));
										rettext += "$"+IntToHex(address,4);
								}
					bytes=2;
								break;
				case AddressMode.Immediate:  /* immediate (byte or word) */
					if( databytes == 1 )  // byte
								{
										rettext += "#$"+GetstringByte(pc+1);
										bytes=2;
					}   // word
								else
								{
										address = GetWord(pc+1);
										rettext += "#";
										if (!CheckLabel(address,ref rettext))
										{
										m_errorList.Add("Unlabeled immediate address at "+IntToHex(pc,4));
										rettext += "$"+IntToHex(address,4);
										}
										bytes=3;
								}
								break;
				case AddressMode.Indexed:  /* indexed + byte offset */
					rettext += "$"+GetstringByte(pc+1)+",X";
					bytes=2;
					break;
				case AddressMode.Direct:  /* direct address */
					if (!CheckLabel(GetByte(pc+1),ref rettext)) {
							rettext += "$"+GetstringByte(pc+1);
					}
					bytes=2;
					break;
				case AddressMode.Extended:  /* extended address */
					address = GetWord(pc+1);
					if (!CheckLabel(address,ref rettext))
					{
							m_errorList.Add("Unlabeled extended address at "+IntToHex(pc,4)+ ": ($"+IntToHex(address,4) +")");
							rettext += "$"+IntToHex(address,4);
					}
					bytes=3;
					break;
				default:   /* inherent address */
					if (opcode == 0x39) {
						//we need to add a return here

					}
					bytes=1;
					break;
			}

			return bytes;
		}
		//-----------------------------------------------------------------------------------------
		private ushort Trace680x ( ushort pc, ref TraceReturn returncode)
		{
			if (GetFlag(pc)> _UNKNOWN ) {  // we need to check if the current address
				returncode = TraceReturn.End;      // has been processed, if so, get outta here.
				return 0;
			}
			// Begin Breakpoint Code -----------------------------------
										if ( pc == 0xE0F6 ) {
											returncode = 0;
										}
			// End Breakpoint Code -------------------------------------
			int address,offset; /* global temps for this function */
			int opcode = GetByte(pc);
			int databytes = Databytes(opcode);
			AddressMode addressmode =  Addressmode(opcode);
			string RetText = Mnemonic(opcode);
			string tempstring=null;
			returncode = 0;
			switch( addressmode )
			{
				case AddressMode.Relative:  /* relative (branches)*/
					SetFlag(pc,_CODE);
					SetFlag(pc+1,_CODE);
					offset = GetByte(pc+1);
					address = pc+2+((offset<128) ? offset : offset-256);
					if ( GetFlag(address) == _UNKNOWN )  /* Check the new entry for previous scan */
						AddEntry (address, _CODE);
					if ( RetText == "bra" ) returncode = TraceReturn.End;
					else if( GetFlag (pc+2) > _UNKNOWN) returncode = TraceReturn.End;
					if (!CheckLabel(address,ref tempstring))
					{
						string Label = "gb_"+IntToHex(m_branchEntryCount,2);
						AddLabel(IntToHex(address,4)+" "+Label);
						m_branchEntryCount++;
					}
					return 2;

				case AddressMode.Immediate:  /* immediate (byte or word) */
					if( databytes == 1 ) 
					{ 
						// byte
						SetFlag(pc,_CODE);
						SetFlag(pc+1,_CODE);
                		return 2;
					}
					if ( databytes == 2)  
					{
						SetFlag(pc,_CODE);
						SetFlag(pc+1,_CODE);
						SetFlag(pc+2,_CODE);
						if (RetText =="ldx") m_xReg = GetWord(pc+1);
						// Add a label
						if (!CheckLabel(GetWord(pc+1),ref tempstring)) {
							string Label = "gj_"+IntToHex(m_subroutineEntryCount,2);
							AddLabel(GetstringWord(pc+1)+" "+Label);
							m_subroutineEntryCount++;
						}
						return 3;
					}
					//shouldn't ever be here
					return 3;
				case AddressMode.Indexed:  /* indexed + byte offset */
				case AddressMode.Direct:  /* direct address */
					SetFlag(pc,_CODE);
					SetFlag(pc+1,_CODE);
					if (RetText =="ldx") m_xReg = 0xffff;
					return 2;
				case AddressMode.Extended:  /* extended address */
					address = GetWord(pc+1);
					SetFlag(pc,_CODE);
					SetFlag(pc+1,_CODE);
					SetFlag(pc+2,_CODE);

					if (  opcode == 0x7E  /*jmp*/ ) 
					{
						/* need to add code for Start Macro Address */
						if ( address == 0xEA78 || address == 0xEAC4) 
						{ 
							// Push new routine
							address = m_xReg;
							if ( GetFlag(address) == _UNKNOWN ) { /* Check the new entry for previous scan */
								if (address < 0xe800) {  // Don't process it if it is in system ROM
									AddEntry (address, _CODE);
									if (!CheckLabel(address,ref tempstring)) {
										string Label = "gj_"+IntToHex(m_subroutineEntryCount,2);
										AddLabel(IntToHex(address,4)+" "+Label);
										m_subroutineEntryCount++;
									}
								}
							}
						}
						AddEntry( GetWord( pc+1), _CODE);
						returncode = TraceReturn.End;
					}
					if ( opcode == 0xBD  /*jsr*/ ) {
						if ( address == 0xEA2F ) {  /* code based delay */
							SetFlag(pc+3, _DATA);
							return 4;
						}
						else if ( address == 0xF3AB ) {  /* start macros */
							/* add the macro entry */
							AddEntry( pc+3, _MACRO);
							returncode = TraceReturn.End;
						}
						else if ( address == 0xEA78 ||
								address == 0xEAC4) { // Push new routine
							address = m_xReg;
							if ( GetFlag(address) == 0 )  /* Check the new entry for previous scan */
								AddEntry (address, _CODE);
							if (!CheckLabel(address,ref tempstring))
							{
								if (address < 0xe800) {  // Don't process it if it is in system ROM
									string Label = "gj_"+IntToHex(m_subroutineEntryCount,2);
									AddLabel(IntToHex(address,4)+" "+Label);
									m_subroutineEntryCount++;
								}
							}
						}
						else if ( address <= 0xffff ) {
							if ( GetFlag(address) == _UNKNOWN )  /* Check the new entry for previous scan */
								AddEntry (address, _CODE);
							if (!CheckLabel(address,ref tempstring))
							{
								if (address < 0xe800) {  // Don't process it if it is in system ROM
									string Label = "gj_"+IntToHex(m_subroutineEntryCount,2);
									AddLabel(IntToHex(address,4)+" "+Label);
									m_subroutineEntryCount++;
								}
							}
							if ( GetFlag(pc+3) > _UNKNOWN ) // address after JSR
								returncode = TraceReturn.End;
						}
					}
					return 3;
				case AddressMode.Inherent:  /* inherent */
						if (   (opcode == 0x39)  /*rts*/
							|| (opcode == 0x3B)  /*rti*/
							|| (opcode == 0x3E)  /*sync*/
							|| (opcode == 0x3F)  /*swi*/ ) {
								returncode = TraceReturn.End;
						}
						SetFlag(pc,_CODE);
						return 1;
				default: /* should be illegal ops only */
						returncode = TraceReturn.End;
						SetFlag(pc,_UNKNOWN);
						return 1;
		 
			}
		}
		//-----------------------------------------------------------------------------------------
		private int DASMmacro ( int pc, ref string returntext)
		{
			string comment=null,bitstring=null,datastring=null;
			ushort i=0,address=0,data=0,val=0;
			ushort offset=0;
			// Begin Breakpoint Code -----------------------------------
									if ( pc == 0xdb5a ) {
											i = 0;
										}
			// End Breakpoint Code -------------------------------------
			int opcode = GetByte(pc);
			string mnemonic = (string)Macros[opcode];
			int macro = opcode>>4;
			int micro = opcode & 0x0F;
			Tab(ref returntext,_TAB1);
			returntext += mnemonic;

			switch (macro) {

				case 0x00:
					Tab(ref returntext,_TAB6);
					switch (micro) {
						case 0:
							returntext+=";PC-100";
							m_outList.Add(returntext);
							break;
						case 2:
							returntext+=";Macro RTS, Save MRA,MRB";
							m_outList.Add(returntext);
							m_outList.Add("");
							break;
						case 3:
							returntext+=";Remove This Thread";
							m_outList.Add(returntext);
							m_outList.Add("");
							break;
						case 4:
							returntext+=";Resume CPU Execution";
							m_outList.Add(returntext);
							break;
						case 5:
							returntext+=";Award Special";
							m_outList.Add(returntext);
							break;
						case 6:
							returntext+=";Award Extra Ball";
							m_outList.Add(returntext);
							break;
						default:
							returntext+=";ILLEGAL MACRO";
							m_outList.Add(returntext);
							break;
					}
					i=1;
					break;
				case 0x01: /* Bit Stuff */
				case 0x02:
					i = MacroDataLength(pc+1);
					returntext += "(";
					if ( ((micro == 0x3) | (micro == 0x7)) & (macro == 0x02)) {  // these two macros are not valid
						returntext +=" "+IntToHex(opcode,2)+";    ---ILLEGAL MACRO---";
						m_outList.Add(returntext);
						break;
					}
					if (micro < 8) {
						if (micro == 0) bitstring = ";Turn ON:";
						else if (micro == 1) bitstring = ";Turn OFF:";
						else if (micro == 2) bitstring = ";Toggle:";
						else if (micro == 3) bitstring = ";Flash:";
						else if (micro == 4) bitstring = ";Turn ON Lamp/Bit @RAM:";
						else if (micro == 5) bitstring = ";Turn OFF Lamp/Bit @RAM:";
						else if (micro == 6) bitstring = ";Toggle Lamp/Bit @RAM:";
						else if (micro == 7) bitstring = ";Flash Lamp/Bit @RAM:";
						data = (ushort)(0x7F & GetByte(pc+1));

						for (int j=0;j<i;j++) {
							if (j!=0) {
								returntext +=",";
								datastring +=",";
							}
							returntext += "$"+IntToHex(GetByte(pc+j+1),2);
							data = (ushort)(0x7F & GetByte(pc+j+1));
							if (macro == 1) {
							if (micro < 4) { // Immediate data
								if (data > 0x3f )  // bit access
									datastring += " Bit#"+IntToHex(data&0x3f,2);
								else   { // lamp area
									datastring += " Lamp#"+IntToHex(data,2);
									if ((string)m_gameData.LampList[data] != "")
										datastring += "("+m_gameData.LampList[data]+")";
								}
							}
							else { //RAM Pointer data
									datastring += IntToHex(GetByte(pc+1),2);
							}
							}
							else { //Here for macros 2x
								data = (ushort)(0x3F & GetByte(pc+j+1));
								if (micro < 4) { // Immediate data
									datastring += " Lamp#"+IntToHex(data,2);
									if ((string)m_gameData.LampList[data] != "")
										datastring += "("+m_gameData.LampList[data]+")";
							}
							else { //RAM Pointer data
									datastring += IntToHex(GetByte(pc+1),2);
							}
							}
						}
						returntext +=")";
						Tab(ref returntext,_TAB6);
						returntext+=bitstring+datastring;
						m_outList.Add(returntext);
					}
					else {  // above 0x17
						datastring =";Effect:";
						for (int j=0;j<i;j++) {
							if (j!=0) returntext +=",";
							data = (ushort)(0xFF & GetByte(pc+j+1));
							returntext += "$"+IntToHex(data,2);
							datastring += " Range #"+IntToHex(data,2);
						}
						returntext += ")";
						Tab(ref returntext,_TAB6);
						returntext+=datastring;
						m_outList.Add(returntext);
					}
					i+=1;
					break;
				case 0x03: /* Soleniods */
					i=(ushort)(micro+1);
					data = GetByte(pc+1);
					returntext += "(";
					if ((data & 0x70) > 0)  // solenoid ON
						datastring = ";Turn ON";
					else
						datastring = ";Turn OFF";
					for (int j=1;j<i;j++) {
						if (j!=1) returntext +=",";
						datastring += " Sol#"+((byte)(data&0xf)).ToString()+":"+m_gameData.SolenoidList[(data&0xf)];
						data = GetByte(pc+j);
						if ((data & 0x70) > 0) 
						{
							returntext += m_gameData.SolenoidList[(data&0x1f)] + "_on";
						}
						else 
						{
							returntext += m_gameData.SolenoidList[(data&0x1f)] + "_off";
						}
						//returntext += "$"+GetstringByte(pc+j);
					}
					returntext += ")";
					Tab(ref returntext,_TAB6);
					//returntext += datastring;
					m_outList.Add(returntext);
					break;
				case 0x04:
					switch (micro) {
						case 0:
							returntext+= "($"+GetstringByte(pc+1)+",$"+GetstringByte(pc+2)+")";
							Tab(ref returntext,_TAB6);
							returntext+=";Sound#"+GetstringByte(pc+1)+"/"+Points(GetByte(pc+2))+" Points";
							i=3;
							break;
						case 1:
							returntext+= "($"+GetstringByte(pc+1)+")";
							Tab(ref returntext,_TAB6);
							returntext+=";"+Points(GetByte(pc+1))+" Points/Chime";
							i=2;
							break;
						case 2:
							data = GetByte(pc+1);
							//returntext+= "($"+IntToHex(data>>4,1)+",$"+IntToHex(data&0x0f,1)+")";
							val = (ushort)(10^(data&0x07));
							returntext+= "("+((byte)(data>>3)).ToString()+","+val.ToString() +")";
							Tab(ref returntext,_TAB6);
							returntext+=";"+Points(GetByte(pc+1))+" Points";
							i=2;
							break;
						case 3:
							returntext+= "($"+GetstringByte(pc+1)+")";
							Tab(ref returntext,_TAB6);
							returntext+=";"+Points(GetByte(pc+1))+" Points/Digit Sound";
							i=2;
							break;
						default:
							returntext+= "($"+IntToHex(micro-2,2)+")";
							Tab(ref returntext,_TAB6);
							returntext+=";CPU Execute Next "+((byte)(micro-2)).ToString()+" Bytes";
							i=1;
							break;
					}
						m_outList.Add(returntext);
					break;
				case 0x05:
					switch (micro) {
						case 0: /* Add RAM Locations: $00,MSD(A) += $00,LSD(A) */
							data = GetByte(pc+1);
							returntext+= "($"+IntToHex(data>>4,1)+",$"+IntToHex(data&0x0f,1)+")";
							Tab(ref returntext,_TAB6);
							returntext+=";RAM,"+IntToHex(data>>4,1)+" += RAM,"+IntToHex(data&0xf,1);
							m_outList.Add(returntext);
							i=2;
							break;
						case 1: /* Copy Game Data: From LSD(A) to MSD(A) */
							data = GetByte(pc+1);
							returntext+= "($"+IntToHex(data>>4,1)+",$"+IntToHex(data&0x0f,1)+")";
							Tab(ref returntext,_TAB6);
							returntext+=";Copy RAM";
							returntext+=";RAM,"+IntToHex(data>>4,1)+" = RAM,"+IntToHex(data&0xf,1);
							m_outList.Add(returntext);
							i=2;
							break;
						case 2: /* Set Priority for this thread */
							returntext+= "($"+GetstringByte(pc+1)+")";
							Tab(ref returntext,_TAB6);
							returntext+=";Priority=#"+IntToHex (GetByte(pc+1),2) ;
							m_outList.Add(returntext);
							i=2;
							break;
						case 3: /* Delay  (Byte) */
							returntext+= "("+GetByte(pc+1).ToString()+")";
							m_outList.Add(returntext);
							i=2;
							break;
						case 4: /* Remove Single Thread m_based on Priority  */
							returntext+= "($"+GetstringByte(pc+1)+",$"+GetstringByte(pc+2)+")";
							Tab(ref returntext,_TAB6);
							returntext+=";Remove Single Thread m_based on Priority";
							m_outList.Add(returntext);
							i=3;
							break;
						case 5: /* Remove Multiple Threads m_based on Priority  */
							returntext+= "($"+GetstringByte(pc+1)+",$"+GetstringByte(pc+2)+")";
							Tab(ref returntext,_TAB6);
							returntext+=";Remove Multiple Threads m_based on Priority";
							m_outList.Add(returntext);
							i=3;
							break;
						case 6: /* Macro JSR Absolute*/
							address = GetWord(pc+1);
							returntext += "(";
							if (!CheckLabel(address,ref returntext)) {
								returntext += "$"+IntToHex(address,4);
							}
							returntext += ")";
							Tab(ref returntext,_TAB6);
							m_outList.Add(returntext);
							i=3;
							break;
						case 7: /* Macro JSRCODE Absolute*/
							address = GetWord(pc+1);
							returntext += "(";
							if (!CheckLabel(address,ref returntext)) {
								returntext += "$"+IntToHex(address,4);
							}
							returntext += ")";
							Tab(ref returntext,_TAB6);
							m_outList.Add(returntext);
							i=3;
							break;
						case 0x8:  // BEQ absolute
						case 0x9:  // BNE absolute
						case 0xA:  // BEQ Relative
						case 0xB:  // BNE Relative
							i = 1;
							returntext += "(";
							comment = GoBranch(pc, ref i);
							if ((micro & 0x02) == 0) i += 1; // absolute

							for (int j=1;j<i;j++) {
								if (j!=1) returntext += ",";
								returntext += "$"+GetstringByte(pc+j);
							}
			
							if ((micro & 0x02) > 0) {
								offset = GetByte(pc+i);
								address = (ushort)(pc+i+1+((offset<128) ? offset : offset-256));
							}
							else {
								address = GetWord(pc+i-1);
							}
							returntext +=",";
							if (!CheckLabel(address,ref returntext)) 
							{
								returntext += "$"+IntToHex(address,4);
							}
							returntext +=")";
							Tab(ref returntext,_TAB6);
							returntext+=";";
							//Set this to equal to turn off showing the bytes
							returntext+=mnemonic;
							returntext+=""+comment;
							returntext+=" to ";
							if (!CheckLabel(address,ref returntext)) {
								returntext += "$"+IntToHex(address,4);
							}
							m_outList.Add(returntext);
							i += 1;
							break;
						case 0xC: /* Here for _JMPD Absolute*/
							address = GetWord(pc+1);
							returntext += "(";
							if (!CheckLabel(address,ref returntext)) {
								returntext += "$"+IntToHex(address,4);
							}
							returntext += ")";
							Tab(ref returntext,_TAB6);
							m_outList.Add(returntext);
							m_outList.Add("");
							i=3;
							break;
						case 0xD: /* Set Switch */
							i = MacroDataLength(pc+1);
							datastring=";Set Sw#:";
							for (int j=0;j<i;j++) {
								if (j!=0) returntext +=",";
								returntext += "($"+GetstringByte(pc+j+1)+")";
								data = (ushort)(0x3f&GetByte(pc+j));
								datastring+=" $"+IntToHex(data,2);
								if ((string)m_gameData.SwitchList[data] != "")
									datastring+="("+m_gameData.SwitchList[data]+")";
							}
							Tab(ref returntext,_TAB6);
							returntext += datastring;
							m_outList.Add(returntext);
							i+=1;
							break;
						case 0xE: /* Clear Switch */
							i = MacroDataLength(pc+1);
							datastring=";Clear Sw#:";
							for (int j=0;j<i;j++) {
								if (j!=0) returntext +=",";
								returntext += "($"+GetstringByte(pc+j+1)+")";
								data = (ushort)(0x3f&GetByte(pc+j+1));
								datastring+=" $"+IntToHex(data,2);
								if ((string)m_gameData.SwitchList[data] != "")
									datastring+="("+m_gameData.SwitchList[data]+")";
							}
							Tab(ref returntext,_TAB6);
							returntext += datastring;
							m_outList.Add(returntext);
							i+=1;
							break;
						default:  /* Here for _JMP Absolute*/
							address = GetWord(pc+1);
							returntext += "(";
							if (!CheckLabel(address,ref returntext)) {
								returntext += "$"+IntToHex(address,4);
							}
							returntext += ")";
							Tab(ref returntext,_TAB6);
							m_outList.Add(returntext);
							m_outList.Add("");
							i=3;
							break;
					}
					break;
				case 0x06: /* Delay Indexed */
					data = (ushort)(GetByte(pc)&0xf);
					returntext+= "($"+IntToHex(data,1)+")";
					Tab(ref returntext,_TAB6);
					returntext+=";Delay RAM$0"+data.ToString();
					m_outList.Add(returntext);
					i=1;
					break;
				case 0x07: /* Delay Immediate */
					data = (ushort)(GetByte(pc)&0xf);
					returntext+= "("+data.ToString()+")";
					m_outList.Add(returntext);
					i=1;
					break;
				case 0x08: /* JMP Relative */
					offset = (ushort)(0xFFF & GetWord(pc));
					address = (ushort)(pc+2+((offset<2048) ? offset : offset-4096));
					returntext += "(";
					if (!CheckLabel(address,ref returntext)) {
								returntext += "$"+IntToHex(address,4);
					}
					returntext += ")";
					Tab(ref returntext,_TAB6);
					m_outList.Add(returntext);
					i=2;
					break;
				case 0x09: /* JSR Relative */
					offset = (ushort)(0xFFF & GetWord(pc));
					address = (ushort)(pc+2+((offset<2048) ? offset : offset-4096));
					returntext += "(";
					if (!CheckLabel(address,ref returntext)) {
								returntext += "$"+IntToHex(address,4);
					}
					returntext += ")";
					Tab(ref returntext,_TAB6);
					m_outList.Add(returntext);
					i=2;
					break;
				case 0x0A: /* JSRCPU Relative */
					offset = (ushort)(0xFFF & GetWord(pc));
					address = (ushort)(pc+2+((offset<2048) ? offset : offset-4096));
					returntext += "(";
					if (!CheckLabel(address,ref returntext)) {
								returntext += "$"+IntToHex(address,4);
					}
					returntext += ")";
					Tab(ref returntext,_TAB5);
					m_outList.Add(returntext);
					i=2;
					break;
				case 0x0B: /* Add RAM */
					data = (ushort)(GetByte(pc)&0xf);
					returntext+= "($"+IntToHex(data,2)+",$"+GetstringByte(pc+1)+")";
					Tab(ref returntext,_TAB6);
					returntext+=";RAM$0"+IntToHex(data,1)+"+=$"+GetstringByte(pc+1);
					m_outList.Add(returntext);
					i=2;
					break;
				case 0x0C: /* Set RAM */
					data = (ushort)(GetByte(pc)&0xf);
					returntext+= "($"+IntToHex(data,2)+",$"+GetstringByte(pc+1)+")";
					Tab(ref returntext,_TAB6);
					returntext+=";RAM$0"+IntToHex(data,1)+"=$"+GetstringByte(pc+1);
					m_outList.Add(returntext);
					i=2;
					break;
				case 0x0D: /* MultiSound */
					data = (ushort)(GetByte(pc)&0x1F);
					returntext+= "($"+IntToHex(data,2)+",$"+GetstringByte(pc+1)+")";
					Tab(ref returntext,_TAB6);
					returntext+=";Sound #"+IntToHex(data,2)+"(x"+GetByte(pc+1)+")";
					m_outList.Add(returntext);
					i=2;
					break;
				case 0x0E: /* Single Sound */
				case 0x0F:
					data = (ushort)(GetByte(pc)&0x1F);
					returntext+= "($"+IntToHex(data,2)+")";
					Tab(ref returntext,_TAB6);
					returntext+=";Sound #"+IntToHex(data,2);
					m_outList.Add(returntext);
					i=1;
					break;
			}
			return i-1;

		}


		//-----------------------------------------------------------------------------------------
		private ushort TraceMacro ( ushort pc, ref TraceReturn returncode)
		{
			if (GetFlag(pc)!= _UNKNOWN ) {  // we need to check if the current address
				returncode = TraceReturn.End;      // has been processed, if so, get outta here.
				return 0;
			}
			//bool logic = false;
			//int index = 0;
			ArrayList branchlist = new ArrayList();
			branchlist.Add("");
			// Begin Breakpoint Code -----------------------------------
									if ( pc == 0xdb5a ) {
											returncode = 0;
										}
			// End Breakpoint Code -------------------------------------
			ushort i,j,address,offset;
			string tempstring="";
			byte opcode = GetByte(pc);
			byte macro = (byte)(opcode>> 4);
			byte micro = (byte)(opcode & 0x0F);
			SetFlag (pc, _MACRO);

			switch (macro) {

				case 0x00:
					switch (micro) {
						case 0x02: /* MRTS */
						case 0x03: /* KILL */
							returncode = TraceReturn.End;
							return 1;
						case 0x04: /* RCPU */
							returncode = TraceReturn.End;
							AddEntry (pc+1, _CODE );
							return 1;
						default:
							return 1;
					}
				case 0x01: /* Lamp Stuff */
				case 0x02:
					i = MacroDataLength(pc+1);
					for (j=0;j<i;j++) {
						SetFlag(pc+1+j,_MACRO);
					}
					return (ushort)(i+1);
				case 0x03: /* Soleniods */
					for (j=0;j<micro;j++) {
						SetFlag(pc+1+j, _MACRO);
						//also mark the solenoid array with the solenoid timer for reference
						byte data = GetByte(pc+1+j);
						byte timer = (byte)(data & 0xE0);
						byte solnum = (byte)(data & 0x1F);
						if (timer > 0)
						{
							m_gameData.SolenoidTimers[solnum] = timer.ToString();
						}
					}
					return (ushort)(micro+1);
				case 0x04: 
					if (micro == 0x00) {
						SetFlag (pc+1, _MACRO);
						SetFlag (pc+2, _MACRO);
						return 3;
					}
					if (micro >= 0x01 && micro <= 0x03) {
						SetFlag (pc+1, _MACRO);
						return 2;
					}
					if (micro >= 0x04 ) {  /* CPU Instructions inside */
						for (j=0;j<(micro-2);j++) {
							if (GetFlag(pc+1+j) == _UNKNOWN) AddEntry(pc+1+j, _CODE);
						}
						return (ushort)(micro-1);
					} 
					//shouldn't ever get here
					return 0;
				case 0x05:
					if (micro <= 0x03) { /* Macros with one data byte */
						SetFlag(pc+1,_MACRO);
						return 2;
					}
					else if (micro == 0x04 || micro == 0x05 ) { /* Remove Threads (2 data)  */
						SetFlag(pc+1,_MACRO);
						SetFlag(pc+2,_MACRO);
						return 3;
					}
					else if (micro == 0x06 ) { /* Macro JSR */
						SetFlag(pc+1,_MACRO);
						SetFlag(pc+2,_MACRO);
						address = GetWord(pc+1);
						if (GetFlag(address) == _UNKNOWN) AddEntry(GetWord(pc+1), _MACRO);
						if (!CheckLabel(address,ref tempstring))
						{
							string Label = "gj_"+IntToHex(m_subroutineEntryCount,2);
							AddLabel(IntToHex(address,4)+" "+Label);
							m_subroutineEntryCount++;
						}
						return 3;
					}
					else if (micro == 0x07 ) { /* Macro JSRCODE*/
						SetFlag(pc+1,_MACRO);
						SetFlag(pc+2,_MACRO);
						address = GetWord(pc+1);
						if (GetFlag(address) == _UNKNOWN) AddEntry(GetWord(pc+1), _CODE);
						if (!CheckLabel(address,ref tempstring))
						{
							string Label = "gj_"+IntToHex(m_subroutineEntryCount,2);
							AddLabel(IntToHex(address,4)+" "+Label);
							m_subroutineEntryCount++;
						}
						return 3;
					}
					else if (micro == 0x08 || micro == 0x09) { // here for absolute branches only
						i = 1;
						tempstring = GoBranch(pc, ref i);
						i+=2; // this is the offset data (end data) for the branch
						SetFlag(pc, _MACRO);
						for (j=0;j<i-1;j++) { // set all middle data to _DATA
							SetFlag(pc+1+j,_MACRO);
						}
						address = GetWord(pc+i-2);
						if ( GetFlag(address) == _UNKNOWN )  { /* Check the new entry for previous scan */
							AddEntry (address, _MACRO);
						}
						if (!CheckLabel(address,ref tempstring))
						{
							string Label = "gb_"+IntToHex(m_branchEntryCount,2);
							AddLabel(IntToHex(address,4)+" "+Label);
							m_branchEntryCount++;
						}
						return i;
					}
					else if (micro == 0x0a || micro == 0x0b) { // here for relative branches only
						i = 1;
						tempstring = GoBranch(pc, ref i);
						i+=1; // this is the offset data (end data) for the branch
						SetFlag(pc, _MACRO);
						for (j=0;j<i-1;j++) { // set all middle data to _DATA
							SetFlag(pc+1+j, _MACRO);
						}
						offset = GetByte(pc+i-1);
						address = (ushort)(pc+i+((offset<128) ? offset : offset-256));
						if ( GetFlag(address) == _UNKNOWN )  { /* Check the new entry for previous scan */
							AddEntry (address, _MACRO);
						}
						if (!CheckLabel(address,ref tempstring))
						{
							string Label = "gb_"+IntToHex(m_branchEntryCount,2);
							AddLabel(IntToHex(address,4)+" "+Label);
							m_branchEntryCount++;
						}
						return i;
					}
					else if (micro == 0x0c) { /* Here for _JMPD */
						returncode = TraceReturn.End;
						SetFlag(pc+1,_MACRO);
						SetFlag(pc+2,_MACRO);
						address = GetWord(pc+1);
						if (GetFlag(address) == _UNKNOWN) {
							AddEntry(GetWord(pc+1), _CODE);
						}
						if (!CheckLabel(address,ref tempstring))
						{
							string Label = "gj_"+IntToHex(m_subroutineEntryCount,2);
							AddLabel(IntToHex(address,4)+" "+Label);
							m_subroutineEntryCount++;
						}
						return 3;
					}
					else if (micro == 0x0d || micro == 0x0e) { /* Switch Routines */
						i = MacroDataLength(pc+1);
						for (j=0;j<i;j++) {
							SetFlag(pc+1+j, _MACRO);
						}
						return (ushort)(i+1);
					}
					else if (micro == 0x0f) { /* Here for _JMP */
						returncode = TraceReturn.End;
						SetFlag(pc+1,_MACRO);
						SetFlag(pc+2,_MACRO);
						address = GetWord(pc+1);
						if (GetFlag(address) == _UNKNOWN) {
							AddEntry(GetWord(pc+1), _MACRO);
						}
						if (!CheckLabel(address,ref tempstring))
						{
							string Label = "gj_"+IntToHex(m_subroutineEntryCount,2);
							AddLabel(IntToHex(address,4)+" "+Label);
							m_subroutineEntryCount++;
						}
						return 3;
					}
					//shouldn't ever get here
					return 3;
				case 0x06: /* Delay Indexed */
				case 0x07: /* Delay Immediate */
					return 1;
				case 0x08: /* JMP Relative */
					returncode = TraceReturn.End;
					SetFlag (pc+1, _MACRO);
					offset = (ushort)((micro<<8)+GetByte(pc+1));
					if ( offset < 2048 ) address = (ushort)(pc+2+offset);
					else address = (ushort)(pc+2+offset-4096);
					//address = pc+2+((offset<2048) ? offset : offset-4096);
					if ( GetFlag(address) == _UNKNOWN )  
					{ /* Check the new entry for previous scan */
						AddEntry (address, _MACRO);
					}
					if (!CheckLabel(address,ref tempstring))
					{
						string Label = "gj_"+IntToHex(m_subroutineEntryCount,2);
						AddLabel(IntToHex(address,4)+" "+Label);
						m_subroutineEntryCount++;
					}
					return 2;
				case 0x09: /* JSR Relative */
					SetFlag (pc+1, _MACRO);
					offset = (ushort)((micro<<8)+GetByte(pc+1));
					if ( offset < 2048 ) address = (ushort)(pc+2+offset);
					else address = (ushort)(pc+2+offset-4096);
					//address = pc+2+((offset<2048) ? offset : offset-4096);
					if ( GetFlag(address) == _UNKNOWN )  { /* Check the new entry for previous scan */
						AddEntry (address, _MACRO);
					}
					if (!CheckLabel(address,ref tempstring))
					{
						string Label = "gj_"+IntToHex(m_subroutineEntryCount,2);
						AddLabel(IntToHex(address,4)+" "+Label);
						m_subroutineEntryCount++;
					}
					return 2;
				case 0x0A: /* JSRCPU Relative */
					SetFlag (pc+1, _MACRO);
					offset = (ushort)((micro<<8)+GetByte(pc+1));
					address = (ushort)(pc+2+((offset<2048) ? offset : offset-4096));
					if ( GetFlag(address) == _UNKNOWN )  { /* Check the new entry for previous scan */
						AddEntry (address, _CODE);
					}
					if (!CheckLabel(address,ref tempstring))
					{
						string Label = "gj_"+IntToHex(m_subroutineEntryCount,2);
						AddLabel(IntToHex(address,4)+" "+Label);
						m_subroutineEntryCount++;
					}
					return 2;
				case 0x0B: /* Add RAM */
				case 0x0C: /* Set RAM */
				case 0x0D: /* MultiSound */
					SetFlag(pc+1, _MACRO);
					return 2;
				case 0x0E: /* Single Sound */
				case 0x0F:
					return 1;
			}

			return 0;
		}
		//------------------------------------------------------------------------------

		private void DumpSystemData()
		{
			// this will spew out the system data in a meaningful way.. :-)
			m_outList.Add(" \t.org $e000");
			m_outList.Add("");
			m_outList.Add(";---------------------------------------------------------------------------");
			m_outList.Add(";  Default game data and basic system tables start at $e000, these can not  ");
			m_outList.Add(";  ever be moved");
			m_outList.Add(";---------------------------------------------------------------------------");
			m_outList.Add("");
			m_outList.Add("gr_gamenumber\t\t.dw $"+GetstringWord(0xe000));
			m_outList.Add("gr_romrevision\t\t.db $"+GetstringByte(0xe002));
			m_outList.Add("gr_cmoscsum\t\t\t.db $"+GetstringByte(0xe003)+",$"+GetstringByte(0xe004));
			m_outList.Add("gr_backuphstd\t\t.db $"+GetstringByte(0xe005));
			m_outList.Add("gr_replay1\t\t\t.db $"+GetstringByte(0xe006));
			m_outList.Add("gr_replay2\t\t\t.db $"+GetstringByte(0xe007));
			m_outList.Add("gr_replay3\t\t\t.db $"+GetstringByte(0xe008));
			m_outList.Add("gr_replay4\t\t\t.db $"+GetstringByte(0xe009));
			m_outList.Add("gr_matchenable\t\t.db $"+GetstringByte(0xe00a));
			m_outList.Add("gr_specialaward\t\t.db $"+GetstringByte(0xe00b));
			m_outList.Add("gr_replayaward\t\t.db $"+GetstringByte(0xe00c));
			m_outList.Add("gr_maxplumbbobtilts\t.db $"+GetstringByte(0xe00d));
			m_outList.Add("gr_numberofballs\t\t.db $"+GetstringByte(0xe00e));
			m_outList.Add("gr_gameadjust1\t\t.db $"+GetstringByte(0xe00f));
			m_outList.Add("gr_gameadjust2\t\t.db $"+GetstringByte(0xe010));
			m_outList.Add("gr_gameadjust3\t\t.db $"+GetstringByte(0xe011));
			m_outList.Add("gr_gameadjust4\t\t.db $"+GetstringByte(0xe012));
			m_outList.Add("gr_gameadjust5\t\t.db $"+GetstringByte(0xe013));
			m_outList.Add("gr_gameadjust6\t\t.db $"+GetstringByte(0xe014));
			m_outList.Add("gr_gameadjust7\t\t.db $"+GetstringByte(0xe015));
			m_outList.Add("gr_gameadjust8\t\t.db $"+GetstringByte(0xe016));
			m_outList.Add("gr_gameadjust9\t\t.db $"+GetstringByte(0xe017));
			m_outList.Add("gr_hstdcredits\t\t.db $"+GetstringByte(0xe018));
			m_outList.Add("gr_max_extraballs\t\t.db $"+GetstringByte(0xe019));
			m_outList.Add("gr_max_credits\t\t.db $"+GetstringByte(0xe01a));
			m_outList.Add(";---------------");
			m_outList.Add(";Pricing Data  |");
			m_outList.Add(";---------------");
			m_outList.Add("");
			m_outList.Add("gr_pricingdata\t\t.db $"+GetstringByte(0xe01b)+"\t;Left Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe01c)+"\t;Center Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe01d)+"\t;Right Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe01e)+"\t;Coin Units Required");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe01f)+"\t;Bonus Coins");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe020)+"\t;Minimum Coin Units");
			m_outList.Add("");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe021)+"\t;Left Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe022)+"\t;Center Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe023)+"\t;Right Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe024)+"\t;Coin Units Required");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe025)+"\t;Bonus Coins");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe026)+"\t;Minimum Coin Units");
			m_outList.Add("");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe027)+"\t;Left Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe028)+"\t;Center Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe029)+"\t;Right Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe02a)+"\t;Coin Units Required");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe02b)+"\t;Bonus Coins");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe02c)+"\t;Minimum Coin Units");
			m_outList.Add("");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe02d)+"\t;Left Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe02e)+"\t;Center Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe02f)+"\t;Right Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe030)+"\t;Coin Units Required");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe031)+"\t;Bonus Coins");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe032)+"\t;Minimum Coin Units");
			m_outList.Add("");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe033)+"\t;Left Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe034)+"\t;Center Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe035)+"\t;Right Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe036)+"\t;Coin Units Required");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe037)+"\t;Bonus Coins");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe038)+"\t;Minimum Coin Units");
			m_outList.Add("");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe039)+"\t;Left Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe03a)+"\t;Center Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe03b)+"\t;Right Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe03c)+"\t;Coin Units Required");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe03d)+"\t;Bonus Coins");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe03e)+"\t;Minimum Coin Units");
			m_outList.Add("");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe03f)+"\t;Left Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe040)+"\t;Center Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe041)+"\t;Right Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe042)+"\t;Coin Units Required");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe043)+"\t;Bonus Coins");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe044)+"\t;Minimum Coin Units");
			m_outList.Add("");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe045)+"\t;Left Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe046)+"\t;Center Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe047)+"\t;Right Coin Mult");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe048)+"\t;Coin Units Required");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe049)+"\t;Bonus Coins");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe04a)+"\t;Minimum Coin Units");
			m_outList.Add("");
			m_outList.Add(";--------------");
			m_outList.Add(";System Data  |");
			m_outList.Add(";--------------");
			m_outList.Add("");
			m_outList.Add("gr_maxthreads\t\t.db $"+GetstringByte(0xe04b));
			m_outList.Add("gr_extendedromtest\t.db $"+GetstringByte(0xe04c));
			m_outList.Add("gr_lastswitch\t\t.db (switchtable_end-switchtable)/3");
			m_outList.Add("gr_numplayers\t\t.db $"+GetstringByte(0xe04e));
			m_outList.Add("");
			m_outList.Add("gr_lamptable_ptr\t\t.dw lamptable");
			m_outList.Add("gr_switchtable_ptr\t.dw switchtable");
			m_outList.Add("gr_soundtable_ptr\t\t.dw soundtable");
			m_outList.Add("");
			m_outList.Add("gr_lampflashrate\t\t.db $"+GetstringByte(0xe055));
			m_outList.Add("");
			m_outList.Add("gr_specialawardsound\t.db $"+GetstringByte(0xe056)+"\t;Special Sound");
			m_outList.Add("gr_p1_startsound\t\t.db $"+GetstringByte(0xe057));
			m_outList.Add("gr_p2_startsound\t\t.db $"+GetstringByte(0xe058));
			m_outList.Add("gr_p3_startsound\t\t.db $"+GetstringByte(0xe058));
			m_outList.Add("gr_p4_startsound\t\t.db $"+GetstringByte(0xe05a));
			m_outList.Add("gr_matchsound\t\t.db $"+GetstringByte(0xe05b));
			m_outList.Add("gr_highscoresound\t\t.db $"+GetstringByte(0xe05c));
			m_outList.Add("gr_gameoversound\t\t.db $"+GetstringByte(0xe05d));
			m_outList.Add("gr_creditsound\t\t.db $"+GetstringByte(0xe05e));
			m_outList.Add("");
			m_outList.Add("gr_eb_lamp_1\t\t.db $"+GetstringByte(0xe05f));
			m_outList.Add("gr_eb_lamp_2\t\t.db $"+GetstringByte(0xe060));
			m_outList.Add("gr_lastlamp\t\t\t.db $"+GetstringByte(0xe061));
			m_outList.Add("gr_hs_lamp\t\t\t.db $"+GetstringByte(0xe062));
			m_outList.Add("gr_match_lamp\t\t.db $"+GetstringByte(0xe063));
			m_outList.Add("gr_bip_lamp\t\t\t.db $"+GetstringByte(0xe064));
			m_outList.Add("gr_gameover_lamp\t\t.db $"+GetstringByte(0xe065));
			m_outList.Add("gr_tilt_lamp\t\t.db $"+GetstringByte(0xe066));
			m_outList.Add("");
			m_outList.Add("gr_gameoverthread_ptr\t.dw gameover_entry");
			m_outList.Add("");
			m_outList.Add("gr_switchtypetable");
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe069)+",$"+GetstringByte(0xe06A));
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe06B)+",$"+GetstringByte(0xe06c));
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe06d)+",$"+GetstringByte(0xe06e));
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe06f)+",$"+GetstringByte(0xe070));
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe071)+",$"+GetstringByte(0xe072));
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe073)+",$"+GetstringByte(0xe074));
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe075)+",$"+GetstringByte(0xe076));
			m_outList.Add("");
			m_outList.Add("gr_playerstartdata\t.db $"+GetstringByte(0xe077)+",$"+GetstringByte(0xe078)+",$"+GetstringByte(0xe079)+",$"+GetstringByte(0xe07a)+",$"+GetstringByte(0xe07b));
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe07c)+",$"+GetstringByte(0xe07d)+",$"+GetstringByte(0xe07e)+",$"+GetstringByte(0xe07f)+",$"+GetstringByte(0xe080));
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe081)+",$"+GetstringByte(0xe082)+",$"+GetstringByte(0xe083)+",$"+GetstringByte(0xe084)+",$"+GetstringByte(0xe085));
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe086)+",$"+GetstringByte(0xe087)+",$"+GetstringByte(0xe088)+",$"+GetstringByte(0xe089)+",$"+GetstringByte(0xe08a));
			m_outList.Add("");
			m_outList.Add("gr_playerresetdata\t.db $"+GetstringByte(0xe08b)+",$"+GetstringByte(0xe08c)+",$"+GetstringByte(0xe08d)+",$"+GetstringByte(0xe08e)+",$"+GetstringByte(0xe08f));
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe090)+",$"+GetstringByte(0xe091)+",$"+GetstringByte(0xe092)+",$"+GetstringByte(0xe093)+",$"+GetstringByte(0xe094));
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe095)+",$"+GetstringByte(0xe096)+",$"+GetstringByte(0xe097)+",$"+GetstringByte(0xe098)+",$"+GetstringByte(0xe099));
			m_outList.Add("\t\t\t\t.db $"+GetstringByte(0xe09a)+",$"+GetstringByte(0xe09b)+",$"+GetstringByte(0xe09c)+",$"+GetstringByte(0xe09d)+",$"+GetstringByte(0xe09e));
			m_outList.Add("");
			EventFormat(0xe09f, ";(Switch Event)","switch_event");
			EventFormat(0xe0a1, ";(Sound Event )","sound_event" );
			EventFormat(0xe0a3, ";(Score Event)" ,"score_event" );
			EventFormat(0xe0a5, ";(Extra Ball Event)","eb_event");
			EventFormat(0xe0a7, ";(Special Event)","special_event");
			EventFormat(0xe0a9, ";(Start Macro Event)","macro_event");
			EventFormat(0xe0ab, ";(Ball Start Event)","ballstart_event");
			EventFormat(0xe0ad, ";(Add Player Event)","addplayer_event");
			EventFormat(0xe0af, ";(Game Over Event)","gameover_event");
			EventFormat(0xe0b1, ";(HSTD Toggle Event)","hstdtoggle_event");
			m_outList.Add("");
			m_outList.Add("\t\t\t.dw hook_reset\t\t;(From $E89F)Reset");
			m_outList.Add("\t\t\t.dw hook_mainloop\t\t;(From $E8B7)Main Loop Begin");
			m_outList.Add("\t\t\t.dw hook_coin\t\t;(From $F770)Coin Accepted");
			m_outList.Add("\t\t\t.dw hook_gamestart\t;(From $F847)New Game Start");
			m_outList.Add("\t\t\t.dw hook_playerinit\t;(From $F8D8)Init New Player");
			m_outList.Add("\t\t\t.dw hook_outhole\t\t;(From $F9BA)Outhole");
			m_outList.Add("");
			m_outList.Add(";------------------------ end system data ---------------------------");
			m_outList.Add("");
		}
		//---------------------------------------------------------------------------
		private bool Trace (ushort pc, byte format)
		{
			ushort bytes;
			TraceReturn returncode = 0;
			bool done = false;

			while (!done)  {
				// breakpoint code start -------------------------------------------
										if (pc == 0xd800) {
											bytes = 0;
										}
				// Breakpoint Code End --------------------------------------------
				if (format == _CODE)
					bytes = Trace680x (pc, ref returncode);
				else  /* format = _MACRO */
					bytes = TraceMacro(pc, ref returncode);
				if ( returncode == TraceReturn.End ) done = true;
				pc += bytes;
			}
			return done;
		}
		//------------------------------------------------------------------------
		// SoundScan():
		//------------------------------------------------------------------------
		private void SoundScan (int entry)
		{
			for (int i=0; i<0x3f; i++) {
				SetFlag(entry+i,(byte)(_SOUNDTABLE+m_soundStringCount));
				if (GetByte(entry+i)==0x3F){
					m_soundStringCount++;
					return;
				}
			}
		}
		//---------------------------------------------------------------------------
		private void EventFormat(int address, string Comment, string LabelName)
		{
			string returnstring = "gr_"+LabelName+"\t\t";
			int offset;
			int opcode = GetByte(address);
			if (opcode == 0x39) { // RTS
				returnstring += "rts\\ .db $00";
				Tab(ref returnstring,_TAB5);
			}
			else if (opcode == 0x20) { // BRA
				returnstring += "bra "+LabelName;
				offset = GetByte(address+1);
				address += (2+((offset<128) ? offset : offset-256));
				Tab(ref returnstring,_TAB5);
			}
			else
				m_errorList.Add("Unknown Instruction in Event Routine: " + LabelName);
			returnstring += Comment;
			m_outList.Add(returnstring);
		}
		//------------------------------------------------------------------------
		private void InitializeLabels() {
		m_labelList.Add("0000	vm_reg_a");
		m_labelList.Add("0001	vm_reg_b");
		m_labelList.Add("0002	game_ram_2");
		m_labelList.Add("0003	game_ram_3");
		m_labelList.Add("0004	game_ram_4");
		m_labelList.Add("0005	game_ram_5");
		m_labelList.Add("0006	game_ram_6");
		m_labelList.Add("0007	game_ram_7");
		m_labelList.Add("0008	game_ram_8");
		m_labelList.Add("0009	game_ram_9");
		m_labelList.Add("000a	game_ram_a");
		m_labelList.Add("000b	game_ram_b");
		m_labelList.Add("000c	game_ram_c");
		m_labelList.Add("000d	game_ram_d");
		m_labelList.Add("000e	game_ram_e");
		m_labelList.Add("000f	game_ram_f");
		m_labelList.Add("0010	lampbuffer0");
		m_labelList.Add("0018	bitflags");
		m_labelList.Add("0020	lampbufferselect");
		m_labelList.Add("0028	lampbuffer1");
		m_labelList.Add("0030	lampflashflag");
		m_labelList.Add("0038	score_p1_b0");
		m_labelList.Add("0040	score_p3_b0");
		m_labelList.Add("0044	score_p4_b0");
		m_labelList.Add("0048	score_p1_b1");
		m_labelList.Add("004c	score_p2_b1");
		m_labelList.Add("0050	score_p3_b1");
		m_labelList.Add("0054	score_p4_b1");
		m_labelList.Add("0058	mbip_b0");
		m_labelList.Add("0059	mbip_b1");
		m_labelList.Add("005a	cred_b0");
		m_labelList.Add("005b	cred_b1");
		m_labelList.Add("005c	dmask_p1");
		m_labelList.Add("005d	dmask_p2");
		m_labelList.Add("005e	dmask_p3");
		m_labelList.Add("005f	dmask_p4");
		m_labelList.Add("0060	comma_flags");
		m_labelList.Add("0061	switch_b0");
		m_labelList.Add("0069	switch_b1");
		m_labelList.Add("0071	switch_b2");
		m_labelList.Add("0079	switch_b3");
		m_labelList.Add("0081	switch_b4");
		m_labelList.Add("0089	irq_counter");
		m_labelList.Add("008a	lamp_index_word");
		m_labelList.Add("008c	lamp_bit");
		m_labelList.Add("008d	comma_data_temp");
		m_labelList.Add("008e	credp1p2_bufferselect");
		m_labelList.Add("008f	mbipp3p4_bufferselect");
		m_labelList.Add("0090	swap_player_displays");
		m_labelList.Add("0091	solenoid_address");
		m_labelList.Add("0093	solenoid_bitpos");
		m_labelList.Add("0094	solenoid_counter");
		m_labelList.Add("0095	irqcount16");
		m_labelList.Add("0096	switch_queue_pointer");
		m_labelList.Add("0098	solenoid_queue_pointer");
		m_labelList.Add("009a	temp1");
		m_labelList.Add("009c	temp2");
		m_labelList.Add("009e	temp3");
		m_labelList.Add("00a0	sys_temp1");
		m_labelList.Add("00a1	sys_temp2");
		m_labelList.Add("00a2	sys_temp3");
		m_labelList.Add("00a3	sys_temp4");
		m_labelList.Add("00a4	sys_temp5");
		m_labelList.Add("00a5	sw_encoded");
		m_labelList.Add("00a6	sys_temp_w2");
		m_labelList.Add("00a8	sys_temp_w3");
		m_labelList.Add("00aa	thread_priority");
		m_labelList.Add("00ab	unused_ram1");
		m_labelList.Add("00ac	irqcount");
		m_labelList.Add("00ad	vm_base");
		m_labelList.Add("00af	vm_nextslot");
		m_labelList.Add("00b1	current_thread");
		m_labelList.Add("00b3	vm_tail_thread");
		m_labelList.Add("00b5	lamp_flash_rate");
		m_labelList.Add("00b6	lamp_flash_count");
		m_labelList.Add("00b7	thread_timer_byte");
		m_labelList.Add("00b8	soundcount");
		m_labelList.Add("00b9	lastsound");
		m_labelList.Add("00ba	cur_sndflags");
		m_labelList.Add("00bb	soundptr");
		m_labelList.Add("00bd	soundirqcount");
		m_labelList.Add("00bf	soundindex_com");
		m_labelList.Add("00c1	sys_soundflags");
		m_labelList.Add("00c2	soundindex");
		m_labelList.Add("00c3	csound_timer");
		m_labelList.Add("00c5	unknown_ram4");
		m_labelList.Add("00c6	unknown_ram5");
		m_labelList.Add("00c7	unknown_ram6");
		m_labelList.Add("00c8	flag_tilt");
		m_labelList.Add("00c9	flag_gameover");
		m_labelList.Add("00ca	flag_bonusball");
		m_labelList.Add("00cb	flags_selftest");
		m_labelList.Add("00cc	num_players");
		m_labelList.Add("00cd	player_up");
		m_labelList.Add("00ce	pscore_buf");
		m_labelList.Add("00d0	num_eb");
		m_labelList.Add("00d1	vm_pc");
		m_labelList.Add("00d3	num_tilt");
		m_labelList.Add("00d4	minutetimer");
		m_labelList.Add("00d6	flag_timer_bip");
		m_labelList.Add("00d7	randomseed");
		m_labelList.Add("00d8	x_temp_1");
		m_labelList.Add("00da	eb_x_temp");
		m_labelList.Add("00dc	credit_x_temp");
		m_labelList.Add("00de	x_temp_2");
		m_labelList.Add("00e0	spare_ram");
		m_labelList.Add("00e1	spare_ram+1");
		m_labelList.Add("00e2	spare_ram+2");
		m_labelList.Add("00e3	spare_ram+3");
		m_labelList.Add("00e4	spare_ram+4");
		m_labelList.Add("00e5	spare_ram+5");
		m_labelList.Add("00e6	spare_ram+6");
		m_labelList.Add("00e7	spare_ram+7");
		m_labelList.Add("0100	cmos_base");
		m_labelList.Add("0100	cmos_csum");
		m_labelList.Add("0102	aud_leftcoins");
		m_labelList.Add("0106	aud_centercoins");
		m_labelList.Add("010a	aud_rightcoins");
		m_labelList.Add("010e	aud_paidcredits");
		m_labelList.Add("0112	aud_specialcredits");
		m_labelList.Add("0116	aud_replaycredits");
		m_labelList.Add("011a	aud_matchcredits");
		m_labelList.Add("011e	aud_totalcredits");
		m_labelList.Add("0122	aud_extraballs");
		m_labelList.Add("0126	aud_avgballtime");
		m_labelList.Add("012a	aud_totalballs");
		m_labelList.Add("012e	aud_game1");
		m_labelList.Add("0132	aud_game2");
		m_labelList.Add("0136	aud_game3");
		m_labelList.Add("013a	aud_game4");
		m_labelList.Add("013e	aud_game5");
		m_labelList.Add("0142	aud_game6");
		m_labelList.Add("0146	aud_game7");
		m_labelList.Add("014a	aud_autocycles");
		m_labelList.Add("014e	aud_hstdcredits");
		m_labelList.Add("0150	aud_replay1times");
		m_labelList.Add("0154	aud_replay2times");
		m_labelList.Add("0158	aud_replay3times");
		m_labelList.Add("015c	aud_replay4times");
		m_labelList.Add("0162	cmos_bonusunits");
		m_labelList.Add("0164	cmos_coinunits");
		m_labelList.Add("0166	aud_currenthstd");
		m_labelList.Add("016e	aud_currentcredits");
		m_labelList.Add("0170	aud_command");
		m_labelList.Add("017d	adj_cmoscsum");
		m_labelList.Add("0181	adj_backuphstd");
		m_labelList.Add("0183	adj_replay1");
		m_labelList.Add("0185	adj_replay2");
		m_labelList.Add("0187	adj_replay3");
		m_labelList.Add("0189	adj_replay4");
		m_labelList.Add("018b	adj_matchenable");
		m_labelList.Add("018d	adj_specialaward");
		m_labelList.Add("018f	adj_replayaward");
		m_labelList.Add("0191	adj_maxplumbbobtilts");
		m_labelList.Add("0193	adj_numberofballs");
		m_labelList.Add("0195	adj_gameadjust1");
		m_labelList.Add("0196	adj_gameadjust1+1");
		m_labelList.Add("0197	adj_gameadjust2");
		m_labelList.Add("0198	adj_gameadjust2+1");
		m_labelList.Add("0199	adj_gameadjust3");
		m_labelList.Add("019a	adj_gameadjust3+1");
		m_labelList.Add("019b	adj_gameadjust4");
		m_labelList.Add("019c	adj_gameadjust4+1");
		m_labelList.Add("019d	adj_gameadjust5");
		m_labelList.Add("019e	adj_gameadjust5+1");
		m_labelList.Add("019f	adj_gameadjust6");
		m_labelList.Add("01a0	adj_gameadjust6+1");
		m_labelList.Add("01a1	adj_gameadjust7");
		m_labelList.Add("01a2	adj_gameadjust7+1");
		m_labelList.Add("01a3	adj_gameadjust8");
		m_labelList.Add("01a4	adj_gameadjust8+1");
		m_labelList.Add("01a5	adj_gameadjust9");
		m_labelList.Add("01a6	adj_gameadjust9+1");
		m_labelList.Add("01a7	adj_hstdcredits");
		m_labelList.Add("01a9	adj_max_extraballs");
		m_labelList.Add("01ab	adj_max_credits");
		m_labelList.Add("01ad	adj_pricecontrol");
		m_labelList.Add("01af	cmos_leftcoinmult");
		m_labelList.Add("01b1	cmos_centercoinmult");
		m_labelList.Add("01b3	cmos_rightcoinmult");
		m_labelList.Add("01b5	cmos_coinsforcredit");
		m_labelList.Add("01b7	cmos_bonuscoins");
		m_labelList.Add("01b9	cmos_minimumcoins");
		m_labelList.Add("01bb	cmos_byteloc");
		m_labelList.Add("1100	switch_queue");
		m_labelList.Add("1118	sol_queue");
		m_labelList.Add("1128	score_queue");
		m_labelList.Add("1130	exe_buffer");
		m_labelList.Add("1140	p1_gamedata");
		m_labelList.Add("1159	p2_gamedata");
		m_labelList.Add("1172	p3_gamedata");
		m_labelList.Add("118b	p4_gamedata");
		m_labelList.Add("2100	pia_sound_data");
		m_labelList.Add("2101	pia_sound_ctrl");
		m_labelList.Add("2102	pia_comma_data");
		m_labelList.Add("2103	pia_comma_ctrl");
		m_labelList.Add("2200	pia_sol_low_data");
		m_labelList.Add("2201	pia_sol_low_ctrl");
		m_labelList.Add("2202	pia_sol_high_data");
		m_labelList.Add("2203	pia_sol_high_ctrl");
		m_labelList.Add("2400	pia_lamp_row_data");
		m_labelList.Add("2401	pia_lamp_row_ctrl");
		m_labelList.Add("2402	pia_lamp_col_data");
		m_labelList.Add("2403	pia_lamp_col_ctrl");
		m_labelList.Add("2800	pia_disp_digit_data");
		m_labelList.Add("2801	pia_disp_digit_ctrl");
		m_labelList.Add("2802	pia_disp_seg_data");
		m_labelList.Add("2803	pia_disp_seg_ctrl");
		m_labelList.Add("3000	pia_switch_return_data");
		m_labelList.Add("3001	pia_switch_return_ctrl");
		m_labelList.Add("3002	pia_switch_strobe_data");
		m_labelList.Add("3003	pia_switch_strobe_ctrl");
		m_labelList.Add("4000	pia_alphanum_digit_data");
		m_labelList.Add("4001	pia_alphanum_digit_ctrl");
		m_labelList.Add("4002	pia_alphanum_seg_data");
		m_labelList.Add("4003	pia_alphanum_seg_ctrl");
		m_labelList.Add("e000	gr_gamenumber");
		m_labelList.Add("e002	gr_romrevision");
		m_labelList.Add("e003	gr_cmoscsum");
		m_labelList.Add("e005	gr_backuphstd");
		m_labelList.Add("e006	gr_replay1");
		m_labelList.Add("e007	gr_replay2");
		m_labelList.Add("e008	gr_replay3");
		m_labelList.Add("e009	gr_replay4");
		m_labelList.Add("e00a	gr_matchenable");
		m_labelList.Add("e00b	gr_specialaward");
		m_labelList.Add("e00c	gr_replayaward");
		m_labelList.Add("e00d	gr_maxplumbbobtilts");
		m_labelList.Add("e00e	gr_numberofballs");
		m_labelList.Add("e00f	gr_gameadjust1");
		m_labelList.Add("e010	gr_gameadjust2");
		m_labelList.Add("e011	gr_gameadjust3");
		m_labelList.Add("e012	gr_gameadjust4");
		m_labelList.Add("e013	gr_gameadjust5");
		m_labelList.Add("e014	gr_gameadjust6");
		m_labelList.Add("e015	gr_gameadjust7");
		m_labelList.Add("e016	gr_gameadjust8");
		m_labelList.Add("e017	gr_gameadjust9");
		m_labelList.Add("e018	gr_hstdcredits");
		m_labelList.Add("e019	gr_max_extraballs");
		m_labelList.Add("e01a	gr_max_credits");
		m_labelList.Add("e01b	gr_pricingdata");
		m_labelList.Add("e04b	gr_maxthreads");
		m_labelList.Add("e04c	gr_extendedromtest");
		m_labelList.Add("e04d	gr_lastswitch");
		m_labelList.Add("e04e	gr_numplayers");
		m_labelList.Add("e04f	gr_lamptable_ptr");
		m_labelList.Add("e051	gr_switchtable_ptr");
		m_labelList.Add("e053	gr_soundtable_ptr");
		m_labelList.Add("e055	gr_lampflashrate");
		m_labelList.Add("e056	gr_specialawardsound");
		m_labelList.Add("e057	gr_p1_startsound");
		m_labelList.Add("e058	gr_p2_startsound");
		m_labelList.Add("e059	gr_p3_startsound");
		m_labelList.Add("e05a	gr_p4_startsound");
		m_labelList.Add("e05b	gr_matchsound");
		m_labelList.Add("e05c	gr_highscoresound");
		m_labelList.Add("e05d	gr_gameoversound");
		m_labelList.Add("e05e	gr_creditsound");
		m_labelList.Add("e05f	gr_eb_lamp_1");
		m_labelList.Add("e060	gr_eb_lamp_2");
		m_labelList.Add("e061	gr_lastlamp");
		m_labelList.Add("e062	gr_hs_lamp");
		m_labelList.Add("e063	gr_match_lamp");
		m_labelList.Add("e064	gr_bip_lamp");
		m_labelList.Add("e065	gr_gameover_lamp");
		m_labelList.Add("e066	gr_tilt_lamp");
		m_labelList.Add("e067	gr_gameoverthread_ptr");
		m_labelList.Add("e069	gr_switchtypetable");
		m_labelList.Add("e077	gr_playerstartdata");
		m_labelList.Add("e08b	gr_playerresetdata");
		m_labelList.Add("e09f	gr_switch_event");
		m_labelList.Add("e0a1	gr_sound_event");
		m_labelList.Add("e0a3	gr_score_event");
		m_labelList.Add("e0a5	gr_eb_event");
		m_labelList.Add("e0a7	gr_special_event");
		m_labelList.Add("e0a9	gr_macro_event");
		m_labelList.Add("e0ab	gr_ballstart_event");
		m_labelList.Add("e0ad	gr_addplayer_event");
		m_labelList.Add("e0af	gr_gameover_event");
		m_labelList.Add("e0b1	gr_hstdtoggle_event");
		m_labelList.Add("e0b3	gr_reset_hook_ptr");
		m_labelList.Add("e0b5	gr_main_hook_ptr");
		m_labelList.Add("e0b7	gr_coin_hook_ptr");
		m_labelList.Add("e0b9	gr_game_hook_ptr");
		m_labelList.Add("e0bb	gr_player_hook_ptr");
		m_labelList.Add("e0bd	gr_outhole_hook_ptr");
		m_labelList.Add("e0bf	gr_irq_entry");
		m_labelList.Add("e0c2	gr_swi_entry");
		m_labelList.Add("e800	reset");
		m_labelList.Add("e83f	csum1");
		m_labelList.Add("e840	init_done");
		m_labelList.Add("e86c	clear_all");
		m_labelList.Add("e8ad	main");
		m_labelList.Add("e8d4	checkswitch");
		m_labelList.Add("e8f0	time");
		m_labelList.Add("e90d	switches");
		m_labelList.Add("e910	next_sw");
		m_labelList.Add("e942	sw_break");
		m_labelList.Add("e946	vm_irqcheck");
		m_labelList.Add("e957	flashlamp");
		m_labelList.Add("e970	solq");
		m_labelList.Add("e98c	snd_queue");
		m_labelList.Add("e9d7	sndnext");
		m_labelList.Add("e9e5	dosound");
		m_labelList.Add("e9fc	check_threads");
		m_labelList.Add("e9ff	nextthread");
		m_labelList.Add("ea24	delaythread");
		m_labelList.Add("ea2f	addthread");
		m_labelList.Add("ea39	dump_thread");
		m_labelList.Add("ea67	killthread");
		m_labelList.Add("ea78	newthread_sp");
		m_labelList.Add("eac4	newthread_06");
		m_labelList.Add("eacc	killthread_sp");
		m_labelList.Add("eaf3	kill_thread");
		m_labelList.Add("eafb	kill_threads");
		m_labelList.Add("eb00	check_threadid");
		m_labelList.Add("eb0a	pri_next");
		m_labelList.Add("eb17	pri_skipme");
		m_labelList.Add("eb23	solbuf");
		m_labelList.Add("eb34	sb01");
		m_labelList.Add("eb39	sb02");
		m_labelList.Add("eb47	set_solenoid");
		m_labelList.Add("eb5f	set_ss_off");
		m_labelList.Add("eb62	set_s_pia");
		m_labelList.Add("eb6b	set_ss_on");
		m_labelList.Add("eb71	soladdr");
		m_labelList.Add("eb82	ssoladdr");
		m_labelList.Add("eb8e	hex2bitpos");
		m_labelList.Add("eb99	comma_million");
		m_labelList.Add("eb9d	comma_thousand");
		m_labelList.Add("eba1	update_commas");
		m_labelList.Add("ebc4	set_comma_bit");
		m_labelList.Add("ebd0	test_mask_b");
		m_labelList.Add("ebdb	update_eb_count");
		m_labelList.Add("ebfa	isnd_pts");
		m_labelList.Add("ebfe	dsnd_pts");
		m_labelList.Add("ec01	snd_pts");
		m_labelList.Add("ec05	score_main");
		m_labelList.Add("ec1d	score_update");
		m_labelList.Add("ec35	su01");
		m_labelList.Add("ec3a	su02");
		m_labelList.Add("ec48	su03");
		m_labelList.Add("ec5e	su04");
		m_labelList.Add("ec72	su05");
		m_labelList.Add("ec7f	hex2dec");
		m_labelList.Add("ec86	score2hex");
		m_labelList.Add("ec95	sh_exit");
		m_labelList.Add("ec96	add_points");
		m_labelList.Add("ecac	checkreplay");
		m_labelList.Add("ece4	get_hs_digits");
		m_labelList.Add("ecee	b_plus10");
		m_labelList.Add("ecf3	split_ab");
		m_labelList.Add("ecfc	isnd_once");
		m_labelList.Add("ed03	sound_sub");
		m_labelList.Add("ed42	isnd_test");
		m_labelList.Add("ed53	isnd_mult");
		m_labelList.Add("ed99	snd_exit_pull");
		m_labelList.Add("ed9b	snd_exit");
		m_labelList.Add("ed9e	send_snd_save");
		m_labelList.Add("eda0	send_snd");
		m_labelList.Add("eda7	do_complex_snd");
		m_labelList.Add("eda9	csnd_loop");
		m_labelList.Add("edbf	store_csndflg");
		m_labelList.Add("ede7	check_sw_mask");
		m_labelList.Add("ee01	sw_ignore");
		m_labelList.Add("ee02	sw_active");
		m_labelList.Add("ee04	sw_down");
		m_labelList.Add("ee15	sw_dtime");
		m_labelList.Add("ee19	sw_trig_yes");
		m_labelList.Add("ee48	sw_proc");
		m_labelList.Add("ee61	check_sw_close");
		m_labelList.Add("ee69	sc01");
		m_labelList.Add("ee95	to_ldx_rts");
		m_labelList.Add("ee98	getswitch");
		m_labelList.Add("eea9	clc_rts");
		m_labelList.Add("eeab	sw_pack");
		m_labelList.Add("eeb8	pack_done");
		m_labelList.Add("eebb	check_sw_open");
		m_labelList.Add("eedb	sw_get_time");
		m_labelList.Add("eef7	sw_tbl_lookup");
		m_labelList.Add("eeff	xplusa");
		m_labelList.Add("ef0f	copy_word");
		m_labelList.Add("ef22	setup_vm_stack");
		m_labelList.Add("ef3f	stack_done");
		m_labelList.Add("ef4d	xplusb");
		m_labelList.Add("ef53	cmosinc_a");
		m_labelList.Add("ef63	cmosinc_b");
		m_labelList.Add("ef69	b_cmosinc");
		m_labelList.Add("ef6f	reset_audits");
		m_labelList.Add("ef74	clr_ram_100");
		m_labelList.Add("ef77	clr_ram");
		m_labelList.Add("ef7d	factory_zeroaudits");
		m_labelList.Add("ef9d	restore_hstd");
		m_labelList.Add("efaf	a_cmosinc");
		m_labelList.Add("efbc	copyblock");
		m_labelList.Add("efd0	loadpricing");
		m_labelList.Add("efe4	copyblock2");
		m_labelList.Add("eff7	sys_irq");
		m_labelList.Add("f10e	pia_ddr_data");
		m_labelList.Add("f122	spec_sol_def");
		m_labelList.Add("f134	lampbuffers");
		m_labelList.Add("f13c	lamp_on");
		m_labelList.Add("f141	lamp_or");
		m_labelList.Add("f147	lamp_commit");
		m_labelList.Add("f157	lamp_done");
		m_labelList.Add("f15b	lamp_off");
		m_labelList.Add("f160	lamp_and");
		m_labelList.Add("f169	lamp_flash");
		m_labelList.Add("f170	lamp_invert");
		m_labelList.Add("f175	lamp_eor");
		m_labelList.Add("f17e	lamp_on_b");
		m_labelList.Add("f183	lamp_off_b");
		m_labelList.Add("f188	lamp_invert_b");
		m_labelList.Add("f18d	lamp_on_1");
		m_labelList.Add("f192	lamp_off_1");
		m_labelList.Add("f197	lamp_invert_1");
		m_labelList.Add("f19c	unpack_byte");
		m_labelList.Add("f1a7	lampm_off");
		m_labelList.Add("f1b6	lampm_noflash");
		m_labelList.Add("f1c7	lampm_f");
		m_labelList.Add("f1ee	lampm_a");
		m_labelList.Add("f1f8	lampm_b");
		m_labelList.Add("f208	lampm_8");
		m_labelList.Add("f213	abx_ret");
		m_labelList.Add("f21a	lampr_start");
		m_labelList.Add("f21f	lr_ret");
		m_labelList.Add("f226	lampr_end");
		m_labelList.Add("f22c	lampr_setup");
		m_labelList.Add("f255	lamp_left");
		m_labelList.Add("f25a	ls_ret");
		m_labelList.Add("f264	lamp_right");
		m_labelList.Add("f26b	lampm_c");
		m_labelList.Add("f26d	lm_test");
		m_labelList.Add("f27c	lampm_e");
		m_labelList.Add("f294	lampm_d");
		m_labelList.Add("f2ea	bit_switch");
		m_labelList.Add("f2ef	bit_lamp_flash");
		m_labelList.Add("f2f4	bit_lamp_buf_1");
		m_labelList.Add("f2f9	bit_lamp_buf_0");
		m_labelList.Add("f2fc	bit_main");
		m_labelList.Add("f318	csum2");
		m_labelList.Add("f319	master_vm_lookup");
		m_labelList.Add("f339	vm_lookup_0x");
		m_labelList.Add("f347	vm_lookup_1x_a");
		m_labelList.Add("f357	vm_lookup_1x_b");
		m_labelList.Add("f35f	vm_lookup_2x");
		m_labelList.Add("f365	vm_lookup_4x");
		m_labelList.Add("f36b	vm_lookup_5x");
		m_labelList.Add("f38b	branch_lookup");
		m_labelList.Add("f3ab	macro_start");
		m_labelList.Add("f3af	macro_rts");
		m_labelList.Add("f3b5	macro_go");
		m_labelList.Add("f3cb	switch_entry");
		m_labelList.Add("f3cf	breg_sto");
		m_labelList.Add("f3d3	vm_control_0x");
		m_labelList.Add("f3db	macro_pcminus100");
		m_labelList.Add("f3e2	macro_code_start");
		m_labelList.Add("f3ea	macro_special");
		m_labelList.Add("f3ef	macro_extraball");
		m_labelList.Add("f3f4	vm_control_1x");
		m_labelList.Add("f3fb	macro_x8f");
		m_labelList.Add("f418	macro_17");
		m_labelList.Add("f41b	macro_x17");
		m_labelList.Add("f433	to_macro_go1");
		m_labelList.Add("f436	vm_control_2x");
		m_labelList.Add("f442	vm_control_3x");
		m_labelList.Add("f44f	vm_control_4x");
		m_labelList.Add("f46b	macro_exec");
		m_labelList.Add("f48c	gettabledata_w");
		m_labelList.Add("f48e	gettabledata_b");
		m_labelList.Add("f495	macro_getnextbyte");
		m_labelList.Add("f49e	getx_rts");
		m_labelList.Add("f4a1	vm_control_5x");
		m_labelList.Add("f4aa	macro_ramadd");
		m_labelList.Add("f4ba	ram_sto2");
		m_labelList.Add("f4bc	to_macro_go2");
		m_labelList.Add("f4bf	macro_ramcopy");
		m_labelList.Add("f4ca	macro_set_pri");
		m_labelList.Add("f4d2	macro_delay_imm_b");
		m_labelList.Add("f4d4	dly_sto");
		m_labelList.Add("f4e2	macro_getnextword");
		m_labelList.Add("f4ea	macro_get2bytes");
		m_labelList.Add("f4ef	macro_rem_th_s");
		m_labelList.Add("f4f6	macro_rem_th_m");
		m_labelList.Add("f4fd	macro_jsr_noreturn");
		m_labelList.Add("f505	pc_sto2");
		m_labelList.Add("f509	macro_a_ram");
		m_labelList.Add("f516	to_getx_rts");
		m_labelList.Add("f518	macro_b_ram");
		m_labelList.Add("f527	macro_jsr_return");
		m_labelList.Add("f529	ret_sto");
		m_labelList.Add("f540	vm_control_6x");
		m_labelList.Add("f544	vm_control_7x");
		m_labelList.Add("f548	vm_control_8x");
		m_labelList.Add("f54a	pc_sto");
		m_labelList.Add("f54c	to_macro_go4");
		m_labelList.Add("f54f	macro_jmp_cpu");
		m_labelList.Add("f558	vm_control_9x");
		m_labelList.Add("f562	vm_control_ax");
		m_labelList.Add("f566	macro_jmp_abs");
		m_labelList.Add("f56b	vm_control_bx");
		m_labelList.Add("f574	ram_sto");
		m_labelList.Add("f578	vm_control_cx");
		m_labelList.Add("f57d	vm_control_dx");
		m_labelList.Add("f587	vm_control_ex");
		m_labelList.Add("f587	vm_control_fx");
		m_labelList.Add("f58e	macro_pcadd");
		m_labelList.Add("f5a4	macro_setswitch");
		m_labelList.Add("f5b0	load_sw_no");
		m_labelList.Add("f5bc	macro_clearswitch");
		m_labelList.Add("f5c7	to_macro_go3");
		m_labelList.Add("f5ca	to_macro_getnextbyte");
		m_labelList.Add("f5cd	macro_branch");
		m_labelList.Add("f5f8	branchdata");
		m_labelList.Add("f615	complexbranch");
		m_labelList.Add("f636	branch_invert");
		m_labelList.Add("f63a	to_rts3");
		m_labelList.Add("f63b	branch_lamp_on");
		m_labelList.Add("f643	test_z");
		m_labelList.Add("f647	branch_lamprangeoff");
		m_labelList.Add("f64a	test_c");
		m_labelList.Add("f64e	branch_lamprangeon");
		m_labelList.Add("f653	branch_tilt");
		m_labelList.Add("f657	ret_false");
		m_labelList.Add("f65a	branch_gameover");
		m_labelList.Add("f65e	ret_true");
		m_labelList.Add("f661	branch_lampbuf1");
		m_labelList.Add("f666	branch_switch");
		m_labelList.Add("f66b	branch_and");
		m_labelList.Add("f670	branch_add");
		m_labelList.Add("f672	branch_or");
		m_labelList.Add("f677	branch_equal");
		m_labelList.Add("f67c	branch_ge");
		m_labelList.Add("f67f	branch_threadpri");
		m_labelList.Add("f686	branch_bitwise");
		m_labelList.Add("f68a	to_rts4");
		m_labelList.Add("f68b	set_logic");
		m_labelList.Add("f6a5	award_special");
		m_labelList.Add("f6b8	credit_special");
		m_labelList.Add("f6bf	award_replay");
		m_labelList.Add("f6cb	give_credit");
		m_labelList.Add("f6d5	extraball");
		m_labelList.Add("f6d6	do_eb");
		m_labelList.Add("f6fe	addcredits");
		m_labelList.Add("f701	addcredit2");
		m_labelList.Add("f72c	coinlockout");
		m_labelList.Add("f749	checkmaxcredits");
		m_labelList.Add("f75c	pull_ba_rts");
		m_labelList.Add("f75f	creditq");
		m_labelList.Add("f77f	ptrx_plus_1");
		m_labelList.Add("f784	ptrx_plus_a");
		m_labelList.Add("f785	ptrx_plus");
		m_labelList.Add("f7a2	coin_accepted");
		m_labelList.Add("f80f	cmos_a_plus_b_cmos");
		m_labelList.Add("f816	divide_ab");
		m_labelList.Add("f829	clr_bonus_coins");
		m_labelList.Add("f833	csum3");
		m_labelList.Add("f834	dec2hex");
		m_labelList.Add("f840	write_range");
		m_labelList.Add("f847	do_game_init");
		m_labelList.Add("f858	add_player");
		m_labelList.Add("f878	initialize_game");
		m_labelList.Add("f894	clear_range");
		m_labelList.Add("f898	to_pula_rts");
		m_labelList.Add("f89a	clear_displays");
		m_labelList.Add("f8a4	store_display_mask");
		m_labelList.Add("f8ad	init_player_game");
		m_labelList.Add("f8bc	setplayerbuffer");
		m_labelList.Add("f8c8	copyplayerdata");
		m_labelList.Add("f8d2	init_player_up");
		m_labelList.Add("f919	disp_mask");
		m_labelList.Add("f926	disp_clear");
		m_labelList.Add("f933	init_player_sys");
		m_labelList.Add("f952	resetplayerdata");
		m_labelList.Add("f994	dump_score_queue");
		m_labelList.Add("f9ab	outhole_main");
		m_labelList.Add("f9cb	saveplayertobuffer");
		m_labelList.Add("f9e3	to_copyblock");
		m_labelList.Add("f9e6	balladjust");
		m_labelList.Add("fa0b	show_hstd");
		m_labelList.Add("fa1e	gameover");
		m_labelList.Add("fa34	powerup_init");
		m_labelList.Add("fa44	set_gameover");
		m_labelList.Add("fa58	show_all_scores");
		m_labelList.Add("fa92	check_hstd");
		m_labelList.Add("fac6	hstd_nextp");
		m_labelList.Add("fad7	set_hstd");
		m_labelList.Add("faf5	update_hstd");
		m_labelList.Add("fb13	hstd_adddig");
		m_labelList.Add("fb17	wordplusbyte");
		m_labelList.Add("fb23	to_rts1");
		m_labelList.Add("fb24	fill_hstd_digits");
		m_labelList.Add("fb30	send_sound");
		m_labelList.Add("fb39	do_match");
		m_labelList.Add("fb80	get_random");
		m_labelList.Add("fb91	to_rts2");
		m_labelList.Add("fb92	credit_button");
		m_labelList.Add("fba3	has_credit");
		m_labelList.Add("fbbc	start_new_game");
		m_labelList.Add("fbc1	lesscredit");
		m_labelList.Add("fbdd	tilt_warning");
		m_labelList.Add("fbe9	do_tilt");
		m_labelList.Add("fbfa	testdata");
		m_labelList.Add("fc04	testlists");
		m_labelList.Add("fc23	selftest_entry");
		m_labelList.Add("fc31	st_diagnostics");
		m_labelList.Add("fc57	do_aumd");
		m_labelList.Add("fc6a	check_adv");
		m_labelList.Add("fc75	check_aumd");
		m_labelList.Add("fc80	st_init");
		m_labelList.Add("fc91	to_clear_range");
		m_labelList.Add("fc94	st_nexttest");
		m_labelList.Add("fca3	to_audadj");
		m_labelList.Add("fca5	do_audadj");
		m_labelList.Add("fccf	show_func");
		m_labelList.Add("fd0b	adjust_func");
		m_labelList.Add("fd16	st_reset");
		m_labelList.Add("fd23	fn_gameid");
		m_labelList.Add("fd2e	fn_gameaud");
		m_labelList.Add("fd30	fn_sysaud");
		m_labelList.Add("fda9	fn_hstd");
		m_labelList.Add("fdb1	fn_replay");
		m_labelList.Add("fde6	cmos_add_d");
		m_labelList.Add("fdef	fn_pricec");
		m_labelList.Add("fe09	fn_prices");
		m_labelList.Add("fe1f	cmos_a");
		m_labelList.Add("fe22	fn_ret");
		m_labelList.Add("fe26	fn_credit");
		m_labelList.Add("fe29	fn_cdtbtn");
		m_labelList.Add("fe33	fn_adj");
		m_labelList.Add("fe3e	fn_command");
		m_labelList.Add("fe43	st_display");
		m_labelList.Add("fe62	st_sound");
		m_labelList.Add("fe8d	st_lamp");
		m_labelList.Add("feac	st_autocycle");
		m_labelList.Add("fecb	st_solenoid");
		m_labelList.Add("fef0	st_switch");
		m_labelList.Add("fefc	st_swnext");
		m_labelList.Add("ff1f	rambad");
		m_labelList.Add("ff2b	diag");
		m_labelList.Add("ff7b	diag_showerror");
		m_labelList.Add("ff7f	tightloop");
		m_labelList.Add("ff81	diag_ramtest");
		m_labelList.Add("ffcb	cmos_error");
		m_labelList.Add("ffd1	block_copy");
		m_labelList.Add("ffe5	cmos_restore");
		m_labelList.Add("fff2	adjust_a");
		m_labelList.Add("fff8	irq_entry");
		m_labelList.Add("fffa	swi_entry");
		m_labelList.Add("fffc	nmi_entry");
		m_labelList.Add("fffe	res_entry");
		}





	}
}
