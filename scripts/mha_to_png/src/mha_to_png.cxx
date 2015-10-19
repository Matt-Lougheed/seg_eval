//ITK includes
#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkExtractImageFilter.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"

// Other includes
#include <string>
#include "boost/filesystem.hpp"

int main(int argc, char *argv[])
{
  // Verify command line arguments
  if (argc < 3)
    {
      std::cerr << "Usage: " << std::endl;
      std::cerr << argv[0] << " inputImageFile" << "frameNumber" << std::endl;
      return EXIT_FAILURE;
    }

  typedef itk::Image<unsigned char, 3> ImageType;
  typedef itk::ImageFileReader<ImageType> ReaderType;
  typedef itk::ImageFileWriter<ImageType> WriterType;
  typedef itk::ExtractImageFilter<ImageType, ImageType> FilterType;
  
  // Read the image
  ReaderType::Pointer reader = ReaderType::New();
  reader->SetFileName(argv[1]);
  reader->Update();

  // Get the frame number to use for PNG
  std::string frameNumberStr(argv[2]);
  int frameNumber = std::atoi(frameNumberStr.c_str());

  if (frameNumber < 0 || frameNumber > reader->GetOutput()->GetLargestPossibleRegion().GetSize()[2])
    {
      std::cerr << "Invalid frame number! It must be >= 0 and <= the volume depth." << std::endl;
      return EXIT_FAILURE;
    }
  
  boost::filesystem::path p(argv[1]);
  std::string newFileName = std::string(p.parent_path().string()) + "/" + p.stem().string() + "_frame.png";
  
  // Set extraction region to be the desired frame
  ImageType::IndexType start;
  start.Fill(0);
  ImageType::SizeType size;
  size[0] = reader->GetOutput()->GetLargestPossibleRegion().GetSize()[0];
  size[1] = reader->GetOutput()->GetLargestPossibleRegion().GetSize()[1];
  size[2] = frameNumber;

  // Extract the region
  ImageType::RegionType region(start, size);
  FilterType::Pointer extractRegionFilter = FilterType::New();
  extractRegionFilter->SetExtractionRegion(region);
  extractRegionFilter->SetInput(reader->GetOutput());
  extractRegionFilter->Update();

  // Write the new file
  WriterType::Pointer writer = WriterType::New();
  writer->SetFileName(newFileName);
  writer->SetInput(extractRegionFilter->GetOutput());
  try {
    writer->Update();
  }
  catch (itk::ExceptionObject &error) {
    std::cerr << "Error: " << error << std::endl;
    return EXIT_FAILURE;
  }
  
  return EXIT_SUCCESS;
}
