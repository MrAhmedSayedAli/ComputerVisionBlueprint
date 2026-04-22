#include "HelpWidget.h"

#include <QLabel>
#include <QTextBrowser>
#include <QVBoxLayout>

HelpWidget::HelpWidget(QWidget* parent) : QWidget(parent) {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(12, 12, 12, 12);
    layout->setSpacing(8);

    auto* title = new QLabel("<b>Computer Vision Blueprint Help</b>", this);
    layout->addWidget(title);

    auto* browser = new QTextBrowser(this);
    browser->setOpenExternalLinks(true);
    browser->setHtml(
        "<h3>Getting started</h3>"
        "<ul>"
        "<li>Drag nodes from the left panel into the scene.</li>"
        "<li>Connect compatible ports to build an image-processing pipeline.</li>"
        "<li>Use <b>File &gt; Save</b> and <b>File &gt; Load</b> to work with stored scenes.</li>"
        "</ul>"
        "<h3>Themes</h3>"
        "<ul>"
        "<li>Use the <b>Theme</b> menu for Light, Dark, or Custom presets.</li>"
        "<li>Open <b>View &gt; Theme Controls</b> to tune custom colors.</li>"
        "<li>Theme choices persist automatically between runs.</li>"
        "</ul>"
        "<h3>New filters</h3>"
        "<ul>"
        "<li><b>Median Blur</b> removes salt-and-pepper noise with an odd kernel size.</li>"
        "<li><b>Bilateral Filter</b> smooths while keeping strong edges.</li>"
        "<li><b>Box Filter</b> and <b>SQR Box Filter</b> expose classic averaging kernels.</li>"
        "<li><b>Filter2D</b> applies a custom 3x3 convolution kernel.</li>"
        "</ul>"
        "<h3>Circle data</h3>"
        "<ul>"
        "<li><b>Circle</b> outputs a single center/radius pair.</li>"
        "<li><b>Circles</b> combines single circles or circle collections for drawing nodes such as <b>Draw Circles</b>.</li>"
        "</ul>"
        "<p>Tip: Keep this dock open while building workflows, or hide it from the <b>View</b> menu.</p>");
    layout->addWidget(browser, 1);
}
