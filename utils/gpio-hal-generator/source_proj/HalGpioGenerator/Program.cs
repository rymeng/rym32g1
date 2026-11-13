using OfficeOpenXml;
using System.Text;
using System.Text.RegularExpressions;

class HalGpioGenerator
{
    private const string DefaultInputPath = "./iomux";
    private const string DefaultOutputPath = "./output";
    private const string PinMuxFileName = "iomux.xlsx";

    static void Main(string[] args)
    {
        try
        {
            // Set EPPlus license context
            ExcelPackage.License.SetNonCommercialPersonal("rymeng");

            // Parse command line arguments
            string inputPath = DefaultInputPath;
            string outputPath = DefaultOutputPath;
            for (int i = 0; i < args.Length; i++)
            {
                string argument = args[i];

                if ((argument == "-h") || (argument == "--help"))
                {
                    PrintUsage();
                    return;
                }
                else if (argument == "--input-dir")
                {
                    if ((i + 1) >= args.Length)
                    {
                        Console.WriteLine("Error:\t" +
                            "--input-dir requires a value.");
                        PrintUsage();
                        Environment.ExitCode = 1;
                        return;
                    }
                    inputPath = args[++i];
                }
                else if (argument.StartsWith("--input-dir=",
                    StringComparison.Ordinal))
                {
                    inputPath = argument["--input-dir=".Length..];
                }
                else if (argument == "--output-dir")
                {
                    if ((i + 1) >= args.Length)
                    {
                        Console.WriteLine("Error:\t" +
                            "--output-dir requires a value.");
                        PrintUsage();
                        Environment.ExitCode = 1;
                        return;
                    }
                    outputPath = args[++i];
                }
                else if (argument.StartsWith("--output-dir=",
                    StringComparison.Ordinal))
                {
                    outputPath = argument["--output-dir=".Length..];
                }
                else
                {
                    Console.WriteLine("Error:\t" +
                        $"unknown argument '{argument}'.");
                    PrintUsage();
                    Environment.ExitCode = 1;
                    return;
                }
            }

            if (string.IsNullOrWhiteSpace(inputPath))
            {
                Console.WriteLine("Error:\t" +
                    "--input-dir value must not be empty.");
                Environment.ExitCode = 1;
                return;
            }

            if (string.IsNullOrWhiteSpace(outputPath))
            {
                Console.WriteLine("Error:\t" +
                    "--output-dir value must not be empty.");
                Environment.ExitCode = 1;
                return;
            }

            Console.WriteLine("Generation BEGIN...");

            if (!TryResolvePinMuxFilePath(inputPath,
                out string pinMuxFilePath))
            {
                Environment.ExitCode = 1;
                return;
            }
            else
            {
                Console.WriteLine("Info:\tinput file: " +
                    Path.GetFullPath(pinMuxFilePath));
                Console.WriteLine("Info:\toutput file: " +
                    Path.GetFullPath(
                        Path.Combine(outputPath, "gpio.h")));

                using var pinMuxFilePackage = new ExcelPackage(
                    new FileInfo(pinMuxFilePath));
                var pinMuxWorksheet = pinMuxFilePackage.Workbook.Worksheets[0];

                // Ensure the output directory exists
                if (!Directory.Exists(outputPath))
                {
                    Directory.CreateDirectory(outputPath);
                    Console.WriteLine("Info:\t" +
                        $"{outputPath} folder created.");
                }

                // Generate gpio.h
                var gpioHeaderFilePath = Path.Combine(outputPath, "gpio.h");
                using var gpioHeaderWriter = new StreamWriter(
                    gpioHeaderFilePath,
                    false,
                    Encoding.UTF8);
                gpioHeaderWriter.NewLine = "\n";

                // Write header comments
                gpioHeaderWriter.WriteLine("/**");
                gpioHeaderWriter.WriteLine("  * @file       gpio.h");
                gpioHeaderWriter.WriteLine("  * @author     " +
                    "Rainer Yutai Meng");
                gpioHeaderWriter.WriteLine("  * @version    v1.0.0");
                gpioHeaderWriter.WriteLine("  * @date       2026/10/31");
                gpioHeaderWriter.WriteLine("  * @brief      " +
                    "RYM32G1 GPIO HAL library.");
                gpioHeaderWriter.WriteLine("  */");
                gpioHeaderWriter.WriteLine("");

                // Write header guards
                gpioHeaderWriter.WriteLine("#ifndef GPIO_H");
                gpioHeaderWriter.WriteLine("#define GPIO_H");
                gpioHeaderWriter.WriteLine("");
                gpioHeaderWriter.WriteLine("#ifdef __cplusplus");
                gpioHeaderWriter.WriteLine("extern \"C\" {");
                gpioHeaderWriter.WriteLine("#endif /* __cplusplus */");
                gpioHeaderWriter.WriteLine("");

                for (int row = 2;
                    row <= pinMuxWorksheet.Dimension.End.Row;
                    row++)
                {
                    // Get GPIO name from the first column
                    string gpioName =
                        pinMuxWorksheet.Cells[row, 1].Text.Trim();
                    if (string.IsNullOrEmpty(gpioName))
                    {
                        continue;
                    }

                    // Get port name and pin number
                    string gpioPortName = gpioName.Substring(1, 1);
                    // Accept both "PA0" and "PA00"; the bit fields in the
                    // device header are named PIN00 through PIN15.
                    int convertedGpioPinNumber =
                        int.Parse(gpioName.Substring(2));
                    string gpioPinNumber =
                        convertedGpioPinNumber.ToString("00");

                    gpioHeaderWriter.WriteLine("#define " +
                        $"{gpioName}_GETVALUE()    " +
                        $"(GPIO{gpioPortName}->" +
                        $"IDR.bit.PIN{gpioPinNumber})");

                    gpioHeaderWriter.WriteLine("#define " +
                        $"{gpioName}_DIR_INPUT()    " +
                        $"(GPIO{gpioPortName}->" +
                        $"GPMODER.bit.PIN{gpioPinNumber} = 0x0UL)");
                    gpioHeaderWriter.WriteLine("#define " +
                        $"{gpioName}_DIR_OUTPUT()    " +
                        $"(GPIO{gpioPortName}->" +
                        $"GPMODER.bit.PIN{gpioPinNumber} = 0x1UL)");

                    gpioHeaderWriter.WriteLine("#define " +
                        $"{gpioName}_OD_DISABLE()    " +
                        $"(GPIO{gpioPortName}->" +
                        $"PADR.bit.PIN{gpioPinNumber} = 0x0UL)");
                    gpioHeaderWriter.WriteLine("#define " +
                        $"{gpioName}_OD_ENABLE()    " +
                        $"(GPIO{gpioPortName}->" +
                        $"PADR.bit.PIN{gpioPinNumber} = 0x1UL)");

                    gpioHeaderWriter.WriteLine("#define " +
                        $"{gpioName}_SET()    " +
                        $"(GPIO{gpioPortName}->" +
                        $"BSETR.reg = 0x1UL << {convertedGpioPinNumber}UL)");
                    gpioHeaderWriter.WriteLine("#define " +
                        $"{gpioName}_CLR()    " +
                        $"(GPIO{gpioPortName}->" +
                        $"BRSTR.reg = 0x1UL << {convertedGpioPinNumber}UL)");
                    gpioHeaderWriter.WriteLine("#define " +
                        $"{gpioName}_TOG()    " +
                        $"(GPIO{gpioPortName}->" +
                        $"BTOGR.reg = 0x1UL << {convertedGpioPinNumber}UL)");

                    if ((convertedGpioPinNumber >= 0) &&
                        (convertedGpioPinNumber <= 7))
                    {
                        gpioHeaderWriter.WriteLine($"#define " +
                            $"AF_GPIO_{gpioName}()    " +
                            $"(GPIO{gpioPortName}->" +
                            $"AFR1.bit.PIN{gpioPinNumber} = 0x0UL)");
                    }
                    else
                    {
                        gpioHeaderWriter.WriteLine($"#define " +
                            $"AF_GPIO_{gpioName}()    " +
                            $"(GPIO{gpioPortName}->" +
                            $"AFR2.bit.PIN{gpioPinNumber} = 0x0UL)");
                    }

                    for (int col = 2; col <= 13; col++)
                    {
                        string gpioAltFunction = pinMuxWorksheet.
                            Cells[row, col].Text.Trim();
                        if (string.IsNullOrEmpty(gpioAltFunction))
                        {
                            continue;
                        }

                        // Get alternate function number
                        int gpioAltFunctionNumber = int.Parse(
                            pinMuxWorksheet.Cells[1, col].
                            Text.Trim()[3..]);

                        string gpioAltFunctionIndexNumber =
                            gpioAltFunctionNumber.ToString("X");

                        if ((convertedGpioPinNumber >= 0) &&
                            (convertedGpioPinNumber <= 7))
                        {
                            gpioHeaderWriter.WriteLine("#define " +
                                $"AF_{gpioAltFunction}_{gpioName}()    " +
                                $"(GPIO{gpioPortName}->" +
                                $"AFR1.bit.PIN{gpioPinNumber} = " +
                                $"0x{gpioAltFunctionIndexNumber}UL)");
                        }
                        else
                        {
                            gpioHeaderWriter.WriteLine("#define " +
                                $"AF_{gpioAltFunction}_{gpioName}()    " +
                                $"(GPIO{gpioPortName}->" +
                                $"AFR2.bit.PIN{gpioPinNumber} = " +
                                $"0x{gpioAltFunctionIndexNumber}UL)");
                        }
                    }
                    gpioHeaderWriter.WriteLine("");
                }

                // Write header guards
                gpioHeaderWriter.WriteLine("#ifdef __cplusplus");
                gpioHeaderWriter.WriteLine("}");
                gpioHeaderWriter.WriteLine("#endif /* __cplusplus */");
                gpioHeaderWriter.WriteLine("");
                gpioHeaderWriter.WriteLine("#endif /* GPIO_H */");

                gpioHeaderWriter.Close();
                Console.WriteLine("Info:\t" +
                    $"{gpioHeaderFilePath} generated successfully.");

                FormatMacroLines(gpioHeaderFilePath);
                Console.WriteLine("Info:\t" +
                    $"{gpioHeaderFilePath} formatted successfully.");

                CommentDuplicateMacroLines(gpioHeaderFilePath);
                Console.WriteLine("Info:\t" +
                    $"{gpioHeaderFilePath} standardized successfully.");

                Console.WriteLine("Generate gpio.h successfully.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error:\t" +
                $"{ex.Message}.");
            Environment.ExitCode = 1;
        }
    }

    private static void PrintUsage()
    {
        Console.WriteLine("Usage:\tHalGpioGenerator " +
            "[--input-dir <path>] [--output-dir <path>]");
        Console.WriteLine("");
        Console.WriteLine("Options:");
        Console.WriteLine("  --input-dir <path>  Directory containing " +
            $"{PinMuxFileName}, or the workbook file itself.");
        Console.WriteLine("                      Default: " +
            $"{DefaultInputPath}");
        Console.WriteLine("  --output-dir <path> Directory that receives " +
            "gpio.h.");
        Console.WriteLine("                      Default: " +
            $"{DefaultOutputPath}");
        Console.WriteLine("  -h, --help          Show this help message.");
    }

    private static bool TryResolvePinMuxFilePath(
        string inputPath,
        out string pinMuxFilePath)
    {
        pinMuxFilePath = string.Empty;

        if (Directory.Exists(inputPath))
        {
            string candidateFilePath =
                Path.Combine(inputPath, PinMuxFileName);
            if (File.Exists(candidateFilePath))
            {
                pinMuxFilePath = candidateFilePath;
                return true;
            }
            else
            {
                Console.WriteLine("Error:\t" +
                    $"{candidateFilePath} not found.");
                return false;
            }
        }
        else if (File.Exists(inputPath))
        {
            pinMuxFilePath = inputPath;
            return true;
        }
        else
        {
            Console.WriteLine("Error:\t" +
                $"{inputPath} not found (expected a directory " +
                $"containing {PinMuxFileName}, or the workbook " +
                "file itself).");
            return false;
        }
    }

    private static void FormatMacroLines(string headerFilePath)
    {
        if (!File.Exists(headerFilePath))
        {
            throw new FileNotFoundException($"Error:\t" +
                $"{headerFilePath} not found.");
        }

        string[] originalLines = File.ReadAllLines(headerFilePath);

        List<FormattableMacroLine> macroLineList = [];
        for (int i = 0; i < originalLines.Length; i++)
        {
            string line = originalLines[i];
            Regex macroLineRegex = new(@"^#define\s+(\S+)\s+(.+)$");
            Match macroLineMatch = macroLineRegex.Match(line);

            if (macroLineMatch.Success)
            {
                int macroNameStartIndex = macroLineMatch.Groups[1].Index;
                int macroNameEndIndex = macroNameStartIndex +
                    macroLineMatch.Groups[1].Length;

                int macroBodyStartIndex = macroLineMatch.Groups[2].Index;
                int macroNameBodySpacesCount =
                    macroBodyStartIndex - macroNameEndIndex;

                macroLineList.Add(
                    new FormattableMacroLine
                    {
                        LineIndex = i,
                        Line = line,
                        MacroNameEndIndex = macroNameEndIndex,
                        MacroBodyStartIndex = macroBodyStartIndex,
                        MacroNameBodySpacesCount = macroNameBodySpacesCount
                    });
            }
            else
            {
                ;
            }
        }

        if (macroLineList.Count == 0)
        {
            return;
        }
        else
        {
            int maxMacroBodyStartIndex = 0;
            foreach (var macro in macroLineList)
            {
                if (macro.MacroBodyStartIndex > maxMacroBodyStartIndex)
                {
                    maxMacroBodyStartIndex = macro.MacroBodyStartIndex;
                }
            }

            string[] processedLines = new string[originalLines.Length];
            Array.Copy(originalLines, processedLines, originalLines.Length);

            foreach (FormattableMacroLine macroLine in macroLineList)
            {
                if (macroLine.MacroBodyStartIndex < maxMacroBodyStartIndex)
                {
                    int spacesToAdd = maxMacroBodyStartIndex -
                        macroLine.MacroBodyStartIndex;
                    string processedLine =
                        macroLine.Line.Substring(0,
                            macroLine.MacroNameEndIndex) +
                        new string(' ',
                            macroLine.MacroNameBodySpacesCount +
                            spacesToAdd) +
                        macroLine.Line.Substring(
                            macroLine.MacroBodyStartIndex);
                    processedLines[macroLine.LineIndex] = processedLine;
                }
                else
                {
                    ;
                }
            }
            using var gpioHeaderWriter = new StreamWriter(
                headerFilePath,
                false,
                Encoding.UTF8);
            gpioHeaderWriter.NewLine = "\n";
            foreach (string line in processedLines)
            {
                gpioHeaderWriter.WriteLine(line);
            }
        }
    }

    private static void CommentDuplicateMacroLines(string headerFilePath)
    {
        if (!File.Exists(headerFilePath))
        {
            throw new FileNotFoundException($"Error:\t" +
                $"{headerFilePath} not found.");
        }

        string[] lines = File.ReadAllLines(headerFilePath);

        List<string> macroNameList = [];
        for (int i = 0; i < lines.Length; i++)
        {
            string line = lines[i];
            Regex macroRegex = new(@"^#define\s+(\S+)");
            Match match = macroRegex.Match(line);

            if (match.Success)
            {
                string macroName = match.Groups[1].Value;
                if (macroNameList.Contains(macroName))
                {
                    lines[i] = "// " + line;
                }
                else
                {
                    macroNameList.Add(macroName);
                }
            }
        }

        using var writer = new StreamWriter(
            headerFilePath,
            false,
            Encoding.UTF8);
        writer.NewLine = "\n";
        foreach (string line in lines)
        {
            writer.WriteLine(line);
        }
    }

    private class FormattableMacroLine
    {
        public required int LineIndex
        {
            get;
            set;
        }

        public required string Line
        {
            get;
            set;
        }

        public required int MacroNameEndIndex
        {
            get;
            set;
        }

        public required int MacroBodyStartIndex
        {
            get;
            set;
        }

        public required int MacroNameBodySpacesCount
        {
            get;
            set;
        }
    }
}
