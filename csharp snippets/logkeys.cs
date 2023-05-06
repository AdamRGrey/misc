[DllImport("user32.dll")]
public static extern int GetAsyncKeyState(Int32 i);
    
static void Main(string[] args)
{
    while (true)
    {
        Thread.Sleep(100);
    
        for (int i = 0; i < 255; i++)
        {
            int keyState = GetAsyncKeyState(i);
            // 32769 should be used for windows 10.
            if (keyState == 1 || keyState == -32767 || keyState == 32769)
            {
                Console.WriteLine((char)i);
                break;
            }
        }
    }
} 
