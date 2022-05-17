using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace wdasm
{
    class Program
    {
		/// <summary>
		/// Big Note: This is super old code that I originally wrote in Borland C++Builder back
		/// in the late 1990's. This is a quick and dirty translation of that code into C#. It 
		/// works but it is quite ugly. Several aspects could be converted to .NET objects but at
		/// this point it would probably just be best to take this into .NET CORE.
		/// </summary>
		/// <param name="args"></param>
        static void Main(string[] args)
        {
            if (args.Length == 1)
            {
				try
				{
					DASM dasm = new DASM();
					string fullPathToConfig = Path.GetFullPath(Path.Combine(Environment.CurrentDirectory, args[0]));
					if (dasm.Execute(fullPathToConfig))
					{
						string outputFile = Path.GetFileNameWithoutExtension(fullPathToConfig) +".asm";
						dasm.SaveOutput(outputFile);
						Console.WriteLine("Generated output file: " + outputFile);
					}
					else
					{
						Console.WriteLine(dasm.GetLastError);
					}
				}
				catch { }
			}
        }
    }
}
