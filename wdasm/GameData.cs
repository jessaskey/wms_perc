using System;
using System.Collections;
using System.IO;

namespace wdasm
{
	/// <summary>
	/// Summary description for GameData.
	/// </summary>
	public class GameData
	{
		private ArrayList m_lampList;
		private ArrayList m_switchList;
		private ArrayList m_switchNameList;
		private ArrayList m_solenoidList;
		private ArrayList m_labelList;
		private ArrayList m_solenoidTimers;

		private string m_gameName;
		private string m_errorString;
		private string m_romLow;
		private string m_romHigh;
		private string m_fileName;

		public GameData() 
		{
			m_gameName = "";

			m_switchList = new ArrayList();
			m_switchNameList = new ArrayList();
			m_lampList = new ArrayList();
			m_solenoidList = new ArrayList();
			m_labelList = new ArrayList();
			m_solenoidTimers = new ArrayList();

			for (int i=0;i<64;i++) 
			{
				m_switchList.Add("sw_notused_" + (i+1).ToString());
				m_switchNameList.Add("");
				m_lampList.Add("lmp_notused_" + (i+1).ToString());
				if (i<32) 
				{
					m_solenoidList.Add("sol_notused_" + (i+1).ToString());
					m_solenoidTimers.Add("");
				}
			}
		}

		public ArrayList LampList { get { return m_lampList;} }
		public ArrayList SwitchList { get { return m_switchList;} }
		public ArrayList SwitchNameList { get { return m_switchNameList;} }
		public ArrayList SolenoidList { get { return m_solenoidList;} }
		public ArrayList LabelList { get { return m_labelList;} }
		public ArrayList SolenoidTimers { get { return m_solenoidTimers;} set { m_solenoidList = value;} }
		public string GameName { get { return m_gameName;} }
		public string ROMHigh { get { return m_romHigh;} }
		public string ROMLow { get { return m_romLow;} }

		public bool LoadFromIni(string filePathName) 
		{
			bool error = false;
			if (File.Exists(filePathName))
			{
				string baseDirectory = Path.GetDirectoryName(filePathName);
				IniStructure GameIni = IniStructure.ReadIni(filePathName);
				// Lets make sure that this bad boy is actually a project file
				if (GameIni.CategoryExists("Project")) 
				{
					m_gameName = GameIni.GetValue("Project","GameName");
					if (m_gameName == "") 
					{
						m_errorString = "'GameName' is not specified in configuration file";
						error = true;
					}
					m_romLow = Path.Combine(baseDirectory,GameIni.GetValue("Project","ROMLow"));
					if (m_romLow == "") 
					{
						m_errorString = "'ROMLow' is not specified in configuration file";
						error = true;
					}
					m_romHigh = Path.Combine(baseDirectory, GameIni.GetValue("Project","ROMHigh"));
					if (m_romHigh == "") 
					{
						m_errorString = "'ROMHigh' is not specified in configuration file";
						error = true;
					}
					m_fileName = GameIni.GetValue("Project","Imports");
					// read in the switch/lamp text here...
					string[] switchdefs = GameIni.GetKeys("Switch Labels");
					foreach (string switchdef in switchdefs) 
					{
						try 
						{
							int index = int.Parse(switchdef);
							if (index > 0 && index <= 64) 
							{
								string val = GameIni.GetValue("Switch Labels",switchdef);
								m_switchList[index-1]=val;
							}
						}
						catch {}
					}

					string[] switchnamedefs = GameIni.GetKeys("Switch Names");
					foreach (string switchnamedef in switchnamedefs) 
					{
						try 
						{
							int index = int.Parse(switchnamedef);
							if (index > 0 && index <= 64) 
							{
								string val = GameIni.GetValue("Switch Names",switchnamedef);
								m_switchNameList[index-1]=val;
							}
						}
						catch {}
					}

					string[] lampdefs = GameIni.GetKeys("Lamp Labels");
					foreach (string lampdef in lampdefs) 
					{
						try 
						{
							int index = int.Parse(lampdef);
							if (index > 0 && index <= 64) 
							{
								string val = GameIni.GetValue("Lamp Labels",lampdef);
								m_lampList[index-1]=val;
							}
						}
						catch {}
					}

					string[] soldefs = GameIni.GetKeys("Solenoid Labels");
					foreach (string soldef in soldefs) 
					{
						try 
						{
							int index = int.Parse(soldef);
							if (index > 0 && index <= 32) 
							{
								string val = GameIni.GetValue("Solenoid Labels",soldef);
								m_solenoidList[index-1]=val;
							}
						}
						catch {}
					}					

//					for (int i=0;i<64;i++) 
//					{
//						m_switchList[i]=GameIni.GetValue("Switch Labels",i.ToString());
//						m_lampList[i]=GameIni.GetValue("Lamp Labels",i.ToString());
//						if (i<32) m_solenoidList[i]=GameIni.GetValue("Solenoid Labels",i.ToString());
//					}
					//Load up any game defintion labels
					if (GameIni.CategoryExists("Labels")) 
					{
						string[] labellist = GameIni.GetKeys("Labels"); 
						foreach (string label in labellist) 
						{
							string line = GameIni.GetValue("Labels",label);
							//string address = label;
							//line.Remove(1,5);
							m_labelList.Add(label + " " + line );
						}
					}
				}
				else 
				{
					m_errorString = "Configuration File is missing 'Project' Section";
					error = true;
				}
			}
			else 
			{
				m_errorString = "Specified Project File Does Not Exist: " + filePathName;
				error = true;
			}
			return !error;
		}

		public string GetLastError() 
		{

			return m_errorString;
		}
	}
}
